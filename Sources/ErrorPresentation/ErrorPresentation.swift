#if canImport(UIKit)
import UIKit

extension UIResponder {
    
    @objc open func willPresentError(_ error: Error) -> Error {
        return error
    }

    @objc open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void = {_ in }) {
        if let next = next {
            next.presentError(willPresentError(willPresentError(error)), didPresentHandler: handler)
        } else {
            UIApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
        }
    }
}

@objc public protocol ErrorPresentationApplicationDelegate: UIApplicationDelegate {
    @objc optional func application(_ application: UIApplication, willPresentError error: Error) -> Error
}

public extension UIApplication {

    @objc override func willPresentError(_ error: Error) -> Error {
        if let delegate = delegate as? ErrorPresentationApplicationDelegate,
            let delegateMethod = delegate.application(_:willPresentError:) {
            return delegateMethod(self, error)
        }
        return super.willPresentError(error)
    }

    @objc override func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void = {_ in }) {
        let error = willPresentError(error)
        if error.isVisibleToUser, let window = windows.first(where: { return $0.isKeyWindow }) {
            Alert(error: error).beginSheetModal(for: window) { (buttonNumber) in
                if let error = error as? RecoverableError {
                    error.attemptRecovery(optionIndex: buttonNumber, resultHandler: handler)
                } else {
                    handler(false)
                }
            }
        } else {
            DispatchQueue.main.async { handler(false) }
        }
    }
}
#elseif canImport(AppKit)
import AppKit

extension NSResponder {
    @objc open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        if let nextResponder = nextResponder {
            nextResponder.presentError(willPresentError(error), didPresentHandler: handler)
        } else {
            NSApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
        }
    }
}

public extension NSApplication {
    @objc override func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        let error = willPresentError(error)
        if error.isVisibleToUser, let window = windows.first(where: { return $0.isKeyWindow && $0.isVisible }) {
            NSAlert(error: error).beginSheetModal(for: window) { (response) in
                if let error = error as? RecoverableError {
                    error.attemptRecovery(optionIndex: response.buttonNumber, resultHandler: handler)
                } else {
                    handler(false)
                }
            }
        } else {
            DispatchQueue.main.async { handler(false) }
        }
    }
}

public extension NSWindowController {
    @objc override func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        if let document = document as? NSDocument {
            document.presentError(willPresentError(error), didPresentHandler: handler)
        } else {
            super.presentError(error, didPresentHandler: handler)
        }
    }
}

extension NSDocumentController {
    @objc open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        NSApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

extension NSDocument {
    @objc open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        NSDocumentController.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

extension NSApplication.ModalResponse {
    var buttonNumber: Int {
        return rawValue - 1000
    }
}
#endif

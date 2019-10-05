#if canImport(UIKit)
import UIKit

extension UIResponder {
    
    @objc open func willPresentError(_ error: Error) -> Error {
        return error
    }

    @objc open func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        next?.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc public protocol ApplicationDelegateWithErrorPresentation: UIApplicationDelegate {
    @objc optional func application(_ application: UIApplication, willPresentError error: Error) -> Error
}

public extension UIApplication {

    @objc override func willPresentError(_ error: Error) -> Error {
        if let delegate = delegate as? ApplicationDelegateWithErrorPresentation,
            let delegateMethod = delegate.application(_:willPresentError:) {
            return delegateMethod(self, error)
        }
        return super.willPresentError(error)
    }

    @objc override func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        let error = willPresentError(error)
        if error.isNonUserVisible {
            return
        }
        if let window = windows.first(where: { return $0.isKeyWindow }) {
            UIAlert(error: error).beginSheetModal(for: window) { (buttonNumber) in
                if let handler = handler {
                    if let error = error as? RecoverableError {
                        error.attemptRecovery(optionIndex: buttonNumber, resultHandler: handler)
                    } else {
                        handler(false)
                    }
                }
            }
        }
    }
}
#elseif canImport(AppKit)
import AppKit

extension NSResponder {
    @objc open func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        nextResponder?.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

public extension NSApplication {
    @objc override func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        let error = willPresentError(error)
        if error.isNonUserVisible {
            return
        }
        if let window = windows.first(where: { return $0.isKeyWindow && $0.isVisible }) {
            NSAlert(error: error).beginSheetModal(for: window) { (response) in
                if let handler = handler {
                    if let error = error as? RecoverableError {
                        error.attemptRecovery(optionIndex: response.buttonNumber, resultHandler: handler)
                    } else {
                        handler(false)
                    }
                }
            }
        }
    }
}

public extension NSWindowController {
    @objc override func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        let error = willPresentError(error)
        if let document = document as? NSDocument {
            document.presentError(error, didPresentHandler: handler)
        } else {
            NSApplication.shared.presentError(error, didPresentHandler: handler)
        }
    }
}

public extension NSWindow {
    @objc override func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        let error = willPresentError(error)
        if let nextResponder = nextResponder {
            nextResponder.presentError(error, didPresentHandler: handler)
        } else {
            NSApplication.shared.presentError(error, didPresentHandler: handler)
        }
    }
}

extension NSDocumentController {
    @objc open func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        NSApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

extension NSDocument {
    @objc open func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        NSDocumentController.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

extension NSApplication.ModalResponse {
    var buttonNumber: Int {
        return rawValue - 1000
    }
}

#endif


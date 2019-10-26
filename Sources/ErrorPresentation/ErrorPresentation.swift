#if canImport(UIKit)
import UIKit

@objc
extension UIResponder {
    
    open func willPresentError(_ error: Error) -> Error {
        return error
    }

    open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void = {_ in }) {
        if let next = next {
            next.presentError(willPresentError(error), didPresentHandler: handler)
        } else {
            UIApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
        }
    }
}

@objc
public protocol ErrorPresentationApplicationDelegate: UIApplicationDelegate {
    @objc
    optional func application(_ application: UIApplication, willPresentError error: Error) -> Error
}

@objc
extension UIApplication {

    override open func willPresentError(_ error: Error) -> Error {
        if let delegate = delegate as? ErrorPresentationApplicationDelegate,
            let delegateMethod = delegate.application(_:willPresentError:) {
            return delegateMethod(self, error)
        }
        return super.willPresentError(error)
    }

    var errorPresentaionWindow: UIWindow? { windows.first(where: { $0.isKeyWindow }) }
    
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void = {_ in }) {
        let error = willPresentError(error)
        if error.isVisibleToUser, let window = errorPresentaionWindow {
            Alert(error: error).presentModal(for: window) { (buttonNumber) in
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
public typealias Alert = NSAlert

@objc
extension NSResponder {
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        if let nextResponder = nextResponder {
            nextResponder.presentError(willPresentError(error), didPresentHandler: handler)
        } else {
            NSApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
        }
    }
}

@objc
extension NSApplication {
    
    var errorPresentaionWindow: NSWindow? { windows.first(where: { $0.isKeyWindow && $0.isVisible }) }
    
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        let error = willPresentError(error)
        if error.isVisibleToUser, let window = errorPresentaionWindow {
            Alert(error: error).presentModal(for: window) { (buttonNumber) in
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

@objc
extension NSWindowController {
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        if let document = document as? NSDocument {
            document.presentError(willPresentError(error), didPresentHandler: handler)
        } else {
            super.presentError(error, didPresentHandler: handler)
        }
    }
}

@objc
extension NSDocumentController {
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        NSApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
extension NSDocument {
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        NSDocumentController.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

#endif

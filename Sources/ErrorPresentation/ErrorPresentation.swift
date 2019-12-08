#if canImport(UIKit)
import UIKit

@objc
extension UIResponder {
    
    open func willPresentError(_ error: Error) -> Error {
        return error
    }

    open func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
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

    override open func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        let error = willPresentError(error)
        switch error {
        case let error as CocoaError:
            if error.code == .userCancelled {
                DispatchQueue.main.async { handler?(false) }
                return
            }
        case let error as URLError:
            if error.code == .cancelled {
                DispatchQueue.main.async { handler?(false) }
                return
            }
        default:
            break
        }
        guard let window = windows.first(where: { $0.isKeyWindow }) else {
            DispatchQueue.main.async { handler?(false) }
            return
        }
        Alert(error: error).presentModal(for: window) { (buttonNumber) in
            let handler = handler ?? { (_) in }
            if let error = error as? RecoverableError {
                error.attemptRecovery(optionIndex: buttonNumber, resultHandler: handler)
            } else {
                handler(false)
            }
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
    
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        let error = willPresentError(error)
        switch error {
        case let error as CocoaError:
            if error.code == .userCancelled {
                DispatchQueue.main.async { handler(false) }
                return
            }
        case let error as URLError:
            if error.code == .cancelled {
                DispatchQueue.main.async { handler(false) }
                return
            }
        default:
            break
        }
        guard let window = windows.first(where: { $0.isKeyWindow && $0.isVisible }) else {
            DispatchQueue.main.async { handler(false) }
            return
        }
        Alert(error: error).presentModal(for: window) { (buttonNumber) in
            if let error = error as? RecoverableError {
                error.attemptRecovery(optionIndex: buttonNumber, resultHandler: handler)
            } else {
                handler(false)
            }
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

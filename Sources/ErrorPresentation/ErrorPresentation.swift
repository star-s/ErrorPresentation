#if canImport(UIKit)
import UIKit

@objc
extension UIResponder {
    
    open func willPresentError(_ error: Error) -> Error {
        return error
    }

    open func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        (next ?? UIApplication.shared).presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
public protocol ErrorPresentationApplicationDelegate: UIApplicationDelegate {
    @objc
    func application(_ application: UIApplication, willPresentError error: Error) -> Error
}

@objc
extension UIApplication {

    override open func willPresentError(_ error: Error) -> Error {
        guard let delegate = delegate as? ErrorPresentationApplicationDelegate else {
            return super.willPresentError(error)
        }
        return delegate.application(self, willPresentError: error)
    }

    override open func presentError(_ error: Error, didPresentHandler handler: ((Bool) -> Void)? = nil) {
        let error = willPresentError(error)
        if passErrorsToNextResponder, let next = next {
            next.presentError(error, didPresentHandler: handler)
            return
        }
        switch error {
        case let error as CocoaError where error.code == .userCancelled:
            handler.map({ DispatchQueue.main.async(execute: $0) })
            return
        case let error as URLError where error.code == .cancelled:
            handler.map({ DispatchQueue.main.async(execute: $0) })
            return
        default:
            break
        }
        guard let window = windows.first(where: { $0.isKeyWindow }) else {
            handler.map({ DispatchQueue.main.async(execute: $0) })
            return
        }
        Alert(error: error).presentModal(for: window) { (buttonNumber) in
            let handler = handler ?? { (_) in }
            guard let error = error as? RecoverableError else {
                handler(false)
                return
            }
            error.attemptRecovery(optionIndex: buttonNumber, resultHandler: handler)
        }
    }
    
    open var passErrorsToNextResponder: Bool {
        get { objc_getAssociatedObject(self, &passErrorKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &passErrorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private var passErrorKey: Void?

@available(iOS 13.0, *)
@objc
public protocol ErrorPresentationSceneDelegate: UISceneDelegate {
    @objc
    func scene(_ scene: UIScene, willPresentError error: Error) -> Error
}

@available(iOS 13.0, *)
@objc
extension UIScene {
    /*
    override open func willPresentError(_ error: Error) -> Error {
        if let delegate = delegate as? ErrorPresentationSceneDelegate {
            return delegate.scene(self, willPresentError: error)
        }
        return super.willPresentError(error)
    }*/
}

#elseif canImport(AppKit)
import AppKit
public typealias Alert = NSAlert

@objc
extension NSResponder {
    
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        (nextResponder ?? NSApplication.shared).presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
extension NSApplication {
    
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        let error = willPresentError(error)
        switch error {
        case let error as CocoaError where error.code == .userCancelled:
            DispatchQueue.main.async(execute: handler)
            return
        case let error as URLError where error.code == .cancelled:
            DispatchQueue.main.async(execute: handler)
            return
        default:
            break
        }
        guard let window = windows.first(where: { $0.isKeyWindow && $0.isVisible }) else {
            DispatchQueue.main.async(execute: handler)
            return
        }
        Alert(error: error).presentModal(for: window) { (buttonNumber) in
            guard let error = error as? RecoverableError else {
                handler(false)
                return
            }
            error.attemptRecovery(optionIndex: buttonNumber, resultHandler: handler)
        }
    }
}

@objc
extension NSWindowController {
    
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (Bool) -> Void) {
        guard let document = document as? NSDocument else {
            super.presentError(error, didPresentHandler: handler)
            return
        }
        document.presentError(willPresentError(error), didPresentHandler: handler)
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

extension DispatchQueue {
    
    func async(execute block: @escaping (Bool) -> Void, parameter: Bool = false) {
        async { block(parameter) }
    }
}

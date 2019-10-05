import Foundation
  
public extension Error {
    var isCancelled: Bool {
        return false
    }
}

public extension Error where Self == CocoaError {
    var isCancelled: Bool {
        return self.code == .userCancelled
    }
}

public extension Error where Self == URLError {
    var isCancelled: Bool {
        return self.code == .cancelled
    }
}

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
        
        if error.isCancelled {
            return
        }
        var errorDescription: String?
        var recoverySuggestion: String?
        
        if let localizedError = error as? LocalizedError {
            errorDescription = localizedError.errorDescription
            recoverySuggestion = localizedError.recoverySuggestion
        } else {
            errorDescription = error.localizedDescription
        }
        let alert = UIAlertController(title: errorDescription, message: nil, preferredStyle: .alert)

        if let recoverableError = error as? RecoverableError {
            alert.message = recoverySuggestion
            let options = recoverableError.recoveryOptions
            let indexOfTheLast = options.count - 1
            
            for option in options.enumerated() {
                let action = UIAlertAction(title: option.element, style: option.offset == indexOfTheLast ? .cancel : .default) { (action) in
                    recoverableError.attemptRecovery(optionIndex: option.offset) { handler?($0) }
                }
                alert.addAction(action)
            }
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                handler?(false)
            }))
        }
        windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
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
        let recoveryResult = presentError(willPresentError(error))
        if let handler = handler {
            DispatchQueue.main.async {
                handler(recoveryResult)
            }
        }
    }
}
#endif


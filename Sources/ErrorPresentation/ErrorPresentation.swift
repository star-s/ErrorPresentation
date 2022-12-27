#if canImport(UIKit)
import UIKit

@objc
extension UIResponder {
    
    open func willPresentError(_ error: Error) -> Error {
        return error
    }

    open func presentError(_ error: Error, didPresentHandler handler: ((_ recovered: Bool) -> Void)? = nil) {
        (next ?? UIApplication.shared).presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
public protocol ErrorPresentationApplicationDelegate: UIApplicationDelegate {
    @objc
    func application(_ application: UIApplication, willPresentError error: Error) -> Error
	@objc
	optional func application(_ application: UIApplication, shouldPassErrorToNextResponder error: Error) -> Bool
	@objc
	optional func application(_ application: UIApplication, shouldSkipErrorPresentation error: Error) -> Bool
}

@objc
extension UIApplication {

    override open func willPresentError(_ error: Error) -> Error {
        guard let delegate = delegate as? ErrorPresentationApplicationDelegate else {
            return super.willPresentError(error)
        }
        return delegate.application(self, willPresentError: error)
    }

    override open func presentError(_ error: Error, didPresentHandler handler: ((_ recovered: Bool) -> Void)? = nil) {
        let error = willPresentError(error)
        if let next = next, shouldPassErrorToNextResponder(error) {
            next.presentError(error, didPresentHandler: handler)
            return
        }
		if shouldSkipPresentingError(error) {
			handler?(false)
			return
		}
        guard let window = windows.first(where: { $0.isKeyWindow }) else {
            handler?(false)
            return
        }
        Alert(error: error).presentModal(for: window) { (buttonNumber) in
            guard let error = error as? RecoverableError else {
                handler?(false)
                return
            }
			error.attemptRecovery(optionIndex: buttonNumber) { recovered in
				handler?(recovered)
			}
        }
    }

	private func shouldPassErrorToNextResponder(_ error: Error) -> Bool {
		guard let delegate = delegate as? ErrorPresentationApplicationDelegate else {
			return false
		}
		return delegate.application?(self, shouldPassErrorToNextResponder: error) ?? false
	}

	private func shouldSkipPresentingError(_ error: Error) -> Bool {
		guard let delegate = delegate as? ErrorPresentationApplicationDelegate else {
			return error.shouldSkipPresentation
		}
		return delegate.application?(self, shouldSkipErrorPresentation: error) ?? error.shouldSkipPresentation
	}
}

#elseif canImport(AppKit)
import AppKit
public typealias Alert = NSAlert

@objc
extension NSResponder {
    
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        (nextResponder ?? NSApplication.shared).presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
extension NSApplication {
    
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        let error = willPresentError(error)
		if error.shouldSkipPresentation {
			handler(false)
			return
		}
        guard let window = windows.first(where: { $0.isKeyWindow && $0.isVisible }) else {
			handler(false)
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
    
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        guard let document = document as? NSDocument else {
            super.presentError(error, didPresentHandler: handler)
            return
        }
        document.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
extension NSDocumentController {
    
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        NSApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
extension NSDocument {
    
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        NSDocumentController.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

#endif

private extension Error {
	var shouldSkipPresentation: Bool {
		switch self {
		case let error as CocoaError:
			return error.code == .userCancelled
		case let error as URLError:
			return error.code == .cancelled
		default:
			return false
		}
	}
}

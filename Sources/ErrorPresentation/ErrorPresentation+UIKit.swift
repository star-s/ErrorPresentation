#if canImport(UIKit)
import UIKit

@objc
extension UIResponder {
    
    open func willPresentError(_ error: Error) -> Error {
        error
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

	private typealias PresentationAnchor = UIWindow

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
		guard let presenter = presentationAnchor(for: error)?.rootViewController?.topLevelPresenter else {
			handler?(false)
			return
		}
		let alert = UIAlertController(error: error) { recoveryOptionIndex in
			guard let error = error as? RecoverableError else {
				handler?(false)
				return
			}
			error.attemptRecovery(optionIndex: recoveryOptionIndex) { recovered in
				handler?(recovered)
			}
		}
		presenter.present(alert, animated: true)
    }

	private func presentationAnchor(for error: Error) -> PresentationAnchor? {
		windows.first(where: { $0.isKeyWindow })
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

private extension UIViewController {
	var topLevelPresenter: UIViewController {
		if let next = presentedViewController {
			return next.topLevelPresenter
		}
		return self
	}
}

#endif

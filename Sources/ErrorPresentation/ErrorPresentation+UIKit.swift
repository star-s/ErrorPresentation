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

// MARK: - UIScene

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
@objc
public protocol ErrorPresentationSceneDelegate: UISceneDelegate {
    @objc
    func scene(_ scene: UIScene, willPresentError error: Error) -> Error
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
@objc
extension UIScene {

    open override func willPresentError(_ error: Error) -> Error {
        guard let delegate = delegate as? ErrorPresentationSceneDelegate else {
            return super.willPresentError(error)
        }
        return delegate.scene(self, willPresentError: error)
    }
}

// MARK: - UIApplication

@objc
public protocol ErrorPresentationApplicationDelegate: UIApplicationDelegate {
    @objc
    func application(_ application: UIApplication, willPresentError error: Error) -> Error
}

@objc
extension UIApplication {

    open override func willPresentError(_ error: Error) -> Error {
        guard let delegate = delegate as? ErrorPresentationApplicationDelegate else {
            return super.willPresentError(error)
        }
        return delegate.application(self, willPresentError: error)
    }

    open override func presentError(_ error: Error, didPresentHandler handler: ((_ recovered: Bool) -> Void)? = nil) {
        let error = willPresentError(error)

        if error.isCancelled {
            handler?(false)
            return
        }
		guard let presenter = errorPresenter else {
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

    private var errorPresenter: UIViewController? {
        guard #available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *) else {
            return windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController?
                .topLevelPresenter
        }
        return connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topLevelPresenter
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

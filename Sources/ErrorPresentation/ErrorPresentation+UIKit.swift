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
		guard let window else {
			handler?(false)
			return
		}
        UIAlertController(error: error, resultHandler: handler).show(on: window)
    }

    private var window: UIWindow? {
        guard #available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *) else {
            return keyWindow
        }
        return connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: { $0.isKeyWindow })
    }
}
#endif

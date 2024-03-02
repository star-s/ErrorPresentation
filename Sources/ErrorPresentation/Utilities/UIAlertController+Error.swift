//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 05/10/2019.
//

#if canImport(UIKit)
import UIKit

public extension UIAlertController {
    convenience init(
        error: Error,
        emptyOptionsButtonTitle: String = "OK",
        resultHandler handler: ((_ recovered: Bool) -> Void)? = nil
    ) {
        self.init(
            title: (error as? LocalizedError)?.errorDescription ?? "",
            message: (error as? LocalizedError)?.message ?? error.localizedDescription,
            preferredStyle: .alert
        )
        if let error = error as? RecoverableError {
            error.recoveryOptions.enumerated().reversed().map { (option) in
                UIAlertAction(title: option.element, style: option.offset == 0 ? .cancel : .default) { (_) in
                    error.attemptRecovery(optionIndex: option.offset) { recovered in
                        handler?(recovered)
                    }
                }
            }.forEach {
                addAction($0)
            }
        }
        if actions.isEmpty {
            addAction(UIAlertAction(title: emptyOptionsButtonTitle, style: .default, handler: { _ in handler?(false) }))
        }
    }

    func show(on window: UIWindow) {
        window
            .rootViewController?
            .topLevelPresenter
            .present(self, animated: true)
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

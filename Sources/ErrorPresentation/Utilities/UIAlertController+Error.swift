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
        completionHandler handler: ((_ recoveryOptionIndex: Int) -> Void)? = nil
    ) {
		self.init(
            title: (error as? LocalizedError)?.errorDescription ?? "",
            message: (error as? LocalizedError)?.message ?? error.localizedDescription,
            preferredStyle: .alert
        )
        (error as? RecoverableError)?.recoveryOptions.enumerated().reversed().map { (option) in
            UIAlertAction(title: option.element, style: option.offset == 0 ? .cancel : .default) { (_) in
                handler?(option.offset)
            }
        }.forEach {
            addAction($0)
        }
		if actions.isEmpty {
			addAction(UIAlertAction(title: emptyOptionsButtonTitle, style: .default, handler: { _ in handler?(0) }))
		}
	}
}
#endif

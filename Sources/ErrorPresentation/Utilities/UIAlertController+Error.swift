//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 05/10/2019.
//

#if canImport(UIKit)
import UIKit

public extension UIAlertController {
	convenience init(error: Error, completionHandler handler: ((_ recoveryOptionIndex: Int) -> Void)? = nil) {
		self.init(title: nil, message: nil, preferredStyle: .alert)

		if let localizedError = error as? LocalizedError {
			title = localizedError.errorDescription ?? ""
			if error is RecoverableError {
				message = [localizedError.failureReason, localizedError.recoverySuggestion].compactMap({ $0 }).joined(separator: "\n\n")
			} else {
				message = localizedError.failureReason
			}
			if [title, message].compactMap({ $0 }).reduce(into: true, { $0 = $0 && $1.isEmpty }) {
				message = localizedError.localizedDescription
			}
		} else {
			message = error.localizedDescription
		}
		if let recoverableError = error as? RecoverableError {
			recoverableError.recoveryOptions.enumerated().reversed().map { (option) in
				UIAlertAction(title: option.element, style: option.offset == 0 ? .cancel : .default) { (_) in
					handler?(option.offset)
				}
			}.forEach({ addAction($0) })
		}
		if actions.isEmpty {
			addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in handler?(0) }))
		}
	}
}

#endif

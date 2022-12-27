//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 05/10/2019.
//

#if canImport(UIKit)
import UIKit

final class Alert: UIAlertController {
    
    public convenience init(error: Error) {
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
                UIAlertAction(title: option.element, style: option.offset == 0 ? .cancel : .default) { [weak self] (_) in
                    self?.selectButtonWith(index: option.offset)
                }
            }.forEach({ addAction($0) })
        }
        if actions.isEmpty {
            addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in self?.selectButtonWith(index: 0) }))
        }
    }
    
    private func selectButtonWith(index: Int) {
        handler?(index)
    }
    
    private var handler: ((Int) -> Void)?
    
    public func presentModal(for window: UIWindow, completionHandler handler: ((Int) -> Void)? = nil) {
        window.rootViewController?.topLevelPresenter.present(self, animated: true) {
            self.handler = handler
        }
    }
}

extension UIViewController {
    
    var topLevelPresenter: UIViewController {
        guard let next = presentedViewController else {
            return self
        }
        return next.topLevelPresenter
    }
}

#elseif canImport(AppKit)
import AppKit

extension NSAlert {
    func presentModal(for window: NSWindow, completionHandler handler: ((Int) -> Void)? = nil) {
        beginSheetModal(for: window) {
			handler?($0.buttonNumber)
		}
    }
}

extension NSApplication.ModalResponse {
    var buttonNumber: Int { rawValue - 1000 }
}

#endif

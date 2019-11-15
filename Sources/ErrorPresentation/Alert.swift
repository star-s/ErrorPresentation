//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 05/10/2019.
//

#if canImport(UIKit)
import UIKit

final class Alert: UIAlertController {
    
    var handler: ((Int) -> Void)? = nil
    
    public convenience init(error: Error) {
        self.init(title: nil, message: nil, preferredStyle: .alert)
        
        if let localizedError = error as? LocalizedError {
            title = localizedError.errorDescription
            if error is RecoverableError {
                message = [localizedError.failureReason, localizedError.recoverySuggestion].compactMap({ $0 }).joined(separator: "\n\n")
            } else {
                message = localizedError.failureReason
            }
        } else {
            title = error.localizedDescription
        }
        if let recoverableError = error as? RecoverableError {
            for option in recoverableError.recoveryOptions.enumerated().reversed() {
                let action = UIAlertAction(title: option.element, style: option.offset == 0 ? .cancel : .default) { [weak self] (_) in
                    self?.selectButtonWith(index: option.offset)
                }
                addAction(action)
            }
        } else {
            addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in self?.selectButtonWith(index: 0) }))
        }
    }
    
    func selectButtonWith(index: Int) {
        if let handler = handler {
            handler(index)
        }
    }
    
    public func presentModal(for window: UIWindow, completionHandler handler: ((Int) -> Void)? = nil) {
        self.handler = handler
        if let rootVC = window.rootViewController {
            rootVC.present(self, animated: true, completion: nil)
        }
    }
}
#elseif canImport(AppKit)
import AppKit

extension NSAlert {
    func presentModal(for window: NSWindow, completionHandler handler: ((Int) -> Void)? = nil) {
        beginSheetModal(for: window, completionHandler: { handler?($0.buttonNumber) })
    }
}

extension NSApplication.ModalResponse {
    var buttonNumber: Int {
        return rawValue - 1000
    }
}

#endif

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
        
        var recoverySuggestion: String?
        
        if let localizedError = error as? LocalizedError {
            title = localizedError.errorDescription
            recoverySuggestion = localizedError.recoverySuggestion
        } else {
            title = error.localizedDescription
        }
        if let recoverableError = error as? RecoverableError {
            message = recoverySuggestion
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
    
    public func beginSheetModal(for sheetWindow: UIWindow, completionHandler handler: ((Int) -> Void)? = nil) {
        self.handler = handler
        if let rootVC = sheetWindow.rootViewController {
            rootVC.present(self, animated:  true, completion: nil)
        }
    }
}

#endif

//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

@available(*, deprecated, message: "Use RecoverableErrorWithOptions instead")
public protocol AsyncRecoverableError: RecoverableErrorWithOptions {
    func attemptRecovery(option: RecoveryOption, resultHandler handler: @escaping (_ recovered: Bool) -> Void)
}

public extension AsyncRecoverableError {
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        fatalError("Synchronous recovery not possible")
    }
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (Bool) -> Void) {
        guard let option = RecoveryOption(recoveryOptions[recoveryOptionIndex]) else {
			assertionFailure("Can't create option from - \(recoveryOptions[recoveryOptionIndex])")
			handler(false)
			return
        }
        attemptRecovery(option: option, resultHandler: handler)
    }
}

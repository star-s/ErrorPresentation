//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

public protocol AsyncRecoverableError: RecoverableErrorWithOptions {
    func attemptRecovery(option: RecoveryOption, resultHandler handler: @escaping (Bool) -> Void)
}

public extension AsyncRecoverableError {
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        fatalError("Synchronous recovery not possible")
    }
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (Bool) -> Void) {
        guard let option = RecoveryOption(stringValue: recoveryOptions[recoveryOptionIndex]) else {
            fatalError("Wrong option index")
        }
        attemptRecovery(option: option, resultHandler: handler)
    }
}

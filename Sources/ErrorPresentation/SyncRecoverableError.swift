//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

public protocol SyncRecoverableError: RecoverableErrorWithOptions {
    func attemptRecovery(option: RecoveryOption) -> Bool
}

public extension SyncRecoverableError {
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        guard let option = RecoveryOption(stringValue: recoveryOptions[recoveryOptionIndex]) else {
            fatalError("Can't create option")
        }
        return attemptRecovery(option: option)
    }
}

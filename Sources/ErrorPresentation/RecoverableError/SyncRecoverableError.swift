//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

@available(*, deprecated, message: "Use RecoverableErrorWithOptions instead")
public protocol SyncRecoverableError: RecoverableErrorWithOptions {
    func attemptRecovery(option: RecoveryOption) -> Bool
}

public extension SyncRecoverableError {
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        guard let option = RecoveryOption(recoveryOptions[recoveryOptionIndex]) else {
            assertionFailure("Can't create option from - \(recoveryOptions[recoveryOptionIndex])")
			return false
        }
        return attemptRecovery(option: option)
    }
}

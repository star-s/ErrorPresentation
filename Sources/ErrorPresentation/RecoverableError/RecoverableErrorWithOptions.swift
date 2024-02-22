//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

public protocol RecoverableErrorWithOptions: RecoverableError {
    associatedtype RecoveryOptions: ErrorRecoveryOption

    func attemptRecovery(option: RecoveryOptions) -> Bool
}

public extension RecoverableErrorWithOptions {

    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        guard let option = RecoveryOptions(recoveryOptions[recoveryOptionIndex]) else {
            assertionFailure("Can't create option from - \(recoveryOptions[recoveryOptionIndex])")
            return false
        }
        return attemptRecovery(option: option)
    }
}

extension RecoverableErrorWithOptions where RecoveryOptions: CaseIterable {

    public var recoveryOptions: [String] {
		RecoveryOptions.allCases.map(\.description)
    }
}

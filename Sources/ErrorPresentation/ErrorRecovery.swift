//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 05/10/2019.
//

import Foundation

public typealias RecoveryOptionType = RawRepresentable & CaseIterable

public protocol AsyncRecoverableError: RecoverableError {
    associatedtype RecoveryOption: RecoveryOptionType
    
    func attemptRecovery(option: RecoveryOption, resultHandler handler: @escaping (Bool) -> Void)
}

public extension AsyncRecoverableError {
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        fatalError("Synchronous recovery not possible")
    }
}

public extension AsyncRecoverableError where RecoveryOption.RawValue == String {
    
    var recoveryOptions: [String] { RecoveryOption.allCases.map({ $0.rawValue }) }
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (Bool) -> Void) {
        guard let option = RecoveryOption(rawValue: recoveryOptions[recoveryOptionIndex]) else {
            fatalError("Wrong option index")
        }
        attemptRecovery(option: option, resultHandler: handler)
    }
}

public protocol SyncRecoverableError: RecoverableError {
    associatedtype RecoveryOption: RecoveryOptionType
    
    func attemptRecovery(option: RecoveryOption) -> Bool
}

public extension SyncRecoverableError where RecoveryOption.RawValue == String {
    
    var recoveryOptions: [String] { RecoveryOption.allCases.map({ $0.rawValue }) }
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        guard let option = RecoveryOption(rawValue: recoveryOptions[recoveryOptionIndex]) else {
            fatalError("Wrong option index")
        }
        return attemptRecovery(option: option)
    }
}

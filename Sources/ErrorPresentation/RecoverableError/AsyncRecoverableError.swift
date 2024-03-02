//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 02.03.2024.
//

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol AsyncRecoverableError: RecoverableError {
    associatedtype RecoveryOptions: ErrorRecoveryOption

    func attemptRecovery(option: RecoveryOptions) async -> Bool
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public extension AsyncRecoverableError {

    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        assertionFailure("Don't use \(#function), use 'attemptRecovery(optionIndex:resultHandler:)' instead")
        return false
    }

    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (_ recovered: Bool) -> Void) {
        Task {
            guard let option = RecoveryOptions(recoveryOptions[recoveryOptionIndex]) else {
                assertionFailure("Can't create option from - \(recoveryOptions[recoveryOptionIndex])")
                handler(false)
                return
            }
            await handler(attemptRecovery(option: option))
        }
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public extension AsyncRecoverableError where RecoveryOptions: CaseIterable {

    var recoveryOptions: [String] {
        RecoveryOptions.allCases.map(\.description)
    }
}

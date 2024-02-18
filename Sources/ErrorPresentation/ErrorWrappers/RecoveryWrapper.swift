//
//  ErrorWithRecovery.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 15.02.2024.
//

import Foundation

public struct RecoveryWrapper<T: ErrorRecoveryOption>: RecoverableError {
    public let error: LocalizedError
    
    public let recoveryOptions: [String]

    fileprivate let recoveryAttempter: (T) throws -> Void

    public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        guard let option = T(recoveryOptions[recoveryOptionIndex]) else {
            assertionFailure("Can't create option from - \(recoveryOptions[recoveryOptionIndex])")
            return false
        }
        do {
            try recoveryAttempter(option)
            return true
        } catch {
            return false
        }
    }
}

extension RecoveryWrapper: LocalizedError {
    public var errorDescription: String?    { error.errorDescription }
    public var failureReason: String?       { error.failureReason }
    public var recoverySuggestion: String?  { error.recoverySuggestion }
    public var helpAnchor: String?          { error.helpAnchor }
}

extension RecoveryWrapper: CustomStringConvertible {
    public var description: String { error.localizedDescription }
}

public extension LocalizedError {

    func addRecovery<T: ErrorRecoveryOption>(
        _ type: T.Type = T.self,
        options: [T],
        _ recoveryAttempter: @escaping (T) throws -> Void
    ) -> RecoveryWrapper<T> {
        RecoveryWrapper(
            error: self,
            recoveryOptions: options.map(\.description),
            recoveryAttempter: recoveryAttempter
        )
    }

    func addRecovery<T: ErrorRecoveryOption & CaseIterable>(
        _ type: T.Type = T.self,
        _ recoveryAttempter: @escaping (T) throws -> Void
    ) -> RecoveryWrapper<T> {
        RecoveryWrapper(
            error: self,
            recoveryOptions: T.allCases.map(\.description),
            recoveryAttempter: recoveryAttempter
        )
    }

    func addRecovery(
        okButtonTitle: String = "OK",
        _ recoveryAttempter: (() throws -> Void)? = nil
    ) -> RecoveryWrapper<String> {
        RecoveryWrapper(
            error: self,
            recoveryOptions: [okButtonTitle]
        ) { _ in
            try recoveryAttempter?()
        }
    }
}

//
//  Error+extensions.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 15.02.2024.
//

import Foundation

public struct LocalizationWrapper: LocalizedError {
    public let error: Error
    
    public let errorDescription: String?
    public let failureReason: String?
    public let recoverySuggestion: String?
}

extension LocalizationWrapper: CustomStringConvertible {
    public var description: String { error.localizedDescription }
}

public extension Error {

    func addLocalization(
        errorDescription: String?,
        failureReason: String? = nil,
        recoverySuggestion: String? = nil
    ) -> LocalizationWrapper {
        LocalizationWrapper(
            error: self,
            errorDescription: errorDescription,
            failureReason: failureReason,
            recoverySuggestion: recoverySuggestion
        )
    }
}

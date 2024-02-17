//
//  NestedErrorProotocol.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 17.02.2024.
//

import Foundation

public protocol WrappedError {
    var nestedError: Error { get }
}

extension LocalizationWrapper: WrappedError {
    public var nestedError: Error {
        guard let container = error as? WrappedError else { return error }
        return container.nestedError
    }
}

extension RecoveryWrapper: WrappedError {
    public var nestedError: Error {
        guard let container = error as? WrappedError else { return error }
        return container.nestedError
    }
}

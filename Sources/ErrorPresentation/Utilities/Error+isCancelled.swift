//
//  Error+Presentable.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 15.02.2024.
//

import Foundation

extension Error {
    var isCancelled: Bool {
        if let cancellationError = self as? CancellationErrorProtocol {
            return cancellationError.isCancellationError
        }
        switch self {
        case let error as CocoaError:
            return error.code == .userCancelled
        case let error as URLError:
            return error.code == .cancelled
        default:
            return false
        }
    }
}

public protocol CancellationErrorProtocol {
    var isCancellationError: Bool { get }
}

public extension CancellationErrorProtocol {
    var isCancellationError: Bool { true }
}

extension LocalizationWrapper: CancellationErrorProtocol {
    public var isCancellationError: Bool { error.isCancelled }
}

extension RecoveryWrapper: CancellationErrorProtocol {
    public var isCancellationError: Bool { error.isCancelled }
}

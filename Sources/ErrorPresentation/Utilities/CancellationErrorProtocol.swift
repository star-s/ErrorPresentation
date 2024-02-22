//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 22.02.2024.
//

import Foundation

public protocol CancellationErrorProtocol {
    var isCancellationError: Bool { get }
}

public extension CancellationErrorProtocol {
    var isCancellationError: Bool { true }
}

extension CancellationError: CancellationErrorProtocol {}

extension LocalizationWrapper: CancellationErrorProtocol {
    public var isCancellationError: Bool { error.isCancelled }
}

extension RecoveryWrapper: CancellationErrorProtocol {
    public var isCancellationError: Bool { error.isCancelled }
}

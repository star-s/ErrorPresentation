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

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension CancellationError: CancellationErrorProtocol {}

extension LocalizationWrapper: CancellationErrorProtocol {
    public var isCancellationError: Bool { error.isCancelled }
}

extension RecoveryWrapper: CancellationErrorProtocol {
    public var isCancellationError: Bool { error.isCancelled }
}

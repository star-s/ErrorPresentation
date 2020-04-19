//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

public protocol ErrorRecoveryOption : CustomDebugStringConvertible, CustomStringConvertible {

    var stringValue: String { get }
    init?(stringValue: String)
}

extension ErrorRecoveryOption {
    
    public var description: String { stringValue }
    public var debugDescription: String { stringValue }
}

extension ErrorRecoveryOption where Self: RawRepresentable, Self.RawValue == String {
    
    public var stringValue: String { rawValue }
    public init?(stringValue: String) { self.init(rawValue: stringValue) }
}

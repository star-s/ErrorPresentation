//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

public protocol ErrorRecoveryOption : LosslessStringConvertible {}

extension ErrorRecoveryOption where Self: RawRepresentable, Self.RawValue == String {
    
    public init?(stringValue: String) {
		self.init(rawValue: stringValue)
	}
}

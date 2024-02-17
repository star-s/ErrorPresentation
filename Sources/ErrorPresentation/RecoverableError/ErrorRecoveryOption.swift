//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

public protocol ErrorRecoveryOption : LosslessStringConvertible {}

extension ErrorRecoveryOption where Self: RawRepresentable, Self.RawValue == String {

	public var description: String { rawValue }

	public init?(_ description: String) {
		self.init(rawValue: description)
	}
}

extension String: ErrorRecoveryOption {}

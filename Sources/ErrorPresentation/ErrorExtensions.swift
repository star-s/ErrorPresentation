//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 05/10/2019.
//

import Foundation

public extension LocalizedError where Self: RawRepresentable, Self.RawValue == String {
    var errorDescription: String? { rawValue }
}

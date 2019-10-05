//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 05/10/2019.
//

import Foundation

extension Error {
    var isNonUserVisible: Bool {
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

public extension LocalizedError where Self: RawRepresentable, Self.RawValue == String {
    var errorDescription: String? {
        return self.rawValue
    }
}

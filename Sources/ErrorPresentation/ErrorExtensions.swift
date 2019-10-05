//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 05/10/2019.
//

import Foundation
  
public extension Error {
    var isCancelled: Bool {
        return false
    }
}

public extension Error where Self == CocoaError {
    var isCancelled: Bool {
        return self.code == .userCancelled
    }
}

public extension Error where Self == URLError {
    var isCancelled: Bool {
        return self.code == .cancelled
    }
}

public extension LocalizedError where Self: RawRepresentable, Self.RawValue == String {
    
    var errorDescription: String? {
        return self.rawValue
    }
}

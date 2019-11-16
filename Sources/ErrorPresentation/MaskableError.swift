//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 16/11/2019.
//

import Foundation

public protocol MaskableError: Error {
    var isMasked: Bool { get }
}

extension CocoaError: MaskableError {
    public var isMasked: Bool { code == .userCancelled }
}

extension URLError: MaskableError {
    public var isMasked: Bool { code == .cancelled }
}

extension NSError: MaskableError {
    public var isMasked: Bool {
        switch self {
        case let error as CocoaError:
            return error.isMasked
        case let error as URLError:
            return error.isMasked
        default:
            return false
        }
    }
}

//
//  Error+Presentable.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 15.02.2024.
//

import Foundation
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

public extension Error {
    var isCancelled: Bool {
        if let cancellationError = self as? CancellationErrorProtocol {
            return cancellationError.isCancellationError
        }
        switch self {
        case let error as CocoaError:
            return error.code == .userCancelled
        case let error as URLError:
            return error.code == .cancelled
        #if canImport(AuthenticationServices)
        case let error as ASWebAuthenticationSessionError:
            return error.code == .canceledLogin
        #endif
        default:
            return false
        }
    }
}

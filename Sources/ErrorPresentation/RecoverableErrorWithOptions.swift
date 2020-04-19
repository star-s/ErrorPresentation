//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

public protocol RecoverableErrorWithOptions: RecoverableError {
    associatedtype RecoveryOption: ErrorRecoveryOption, CaseIterable
}

extension RecoverableErrorWithOptions {
    
    public var recoveryOptions: [String] {
        RecoveryOption.allCases.map({ $0.stringValue })
    }
}

//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 19/04/2020.
//

import Foundation

public protocol RecoverableErrorWithOptions: RecoverableError {
    associatedtype RecoveryOption: ErrorRecoveryOption
}

extension RecoverableErrorWithOptions where RecoveryOption: CaseIterable {
    
    public var recoveryOptions: [String] {
		RecoveryOption.allCases.map(\.description)
    }
}

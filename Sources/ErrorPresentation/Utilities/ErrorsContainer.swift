//
//  ErrorsContainer.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 15.02.2024.
//

import Foundation

public protocol ErrorsContainer {
    var underlyingErrors: [Error] { get }
}

extension Array: Error where Element: Error {}

extension Array: ErrorsContainer where Element: Error {
    public var underlyingErrors: [Error] { self }
}

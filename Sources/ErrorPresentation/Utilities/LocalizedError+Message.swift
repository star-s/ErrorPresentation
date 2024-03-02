//
//  File.swift
//  
//
//  Created by Sergey Starukhin on 02.03.2024.
//

import Foundation

internal extension LocalizedError {
    var message: String {
        let message = [
            failureReason,
            recoverySuggestion
        ]
            .compactMap({ $0 })
            .joined(separator: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return hasNoTitle && message.isEmpty ? localizedDescription : message
    }

    var hasNoTitle: Bool {
        guard let errorDescription else {
            return true
        }
        return errorDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }
}

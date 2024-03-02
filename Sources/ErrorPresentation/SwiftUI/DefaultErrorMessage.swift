//
//  DefaultErrorMessage.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 16.02.2024.
//

import SwiftUI

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct DefaultErrorMessage: View {

    public var body: some View {
        Text(message)
    }

    private let message: String

    public init(error: Error) {
        guard let localizedError = error as? LocalizedError else {
            message = error.localizedDescription
            return
        }
        message = localizedError.message
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
#Preview {
    VStack {
        Spacer()
        DefaultErrorMessage(
            error: URLError(.badURL).addLocalization(
                errorDescription: "description",
                failureReason: "failure reason",
                recoverySuggestion: "recovery suggestion"
            )
        ).border(.blue)
        Spacer()
        DefaultErrorMessage(
            error: URLError(.badURL).addLocalization(
                errorDescription: nil,
                failureReason: "",
                recoverySuggestion: ""
            )
        ).border(.red)
        Spacer()
        DefaultErrorMessage(
            error: URLError(.badServerResponse)
        ).border(.gray)
        Spacer()
    }
}

private extension LocalizedError {
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

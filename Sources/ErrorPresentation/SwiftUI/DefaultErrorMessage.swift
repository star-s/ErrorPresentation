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
        let message = [
            localizedError.failureReason,
            localizedError.recoverySuggestion
        ]
            .compactMap({ $0 })
            .joined(separator: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        self.message = message.isEmpty && (localizedError.errorDescription ?? "").isEmpty ?
            localizedError.localizedDescription :
            message
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
#Preview {
    VStack {
        DefaultErrorMessage(error: URLError(.badURL).addLocalization(
            errorDescription: "description",
            failureReason: "failure reason",
            recoverySuggestion: "recovery suggestion"
        )).border(.blue)

        DefaultErrorMessage(error: URLError(.badURL).addLocalization(
            errorDescription: nil,
            failureReason: "",
            recoverySuggestion: ""
        )).border(.red)
    }
}
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
        message = (error as? LocalizedError)?.message ?? error.localizedDescription
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

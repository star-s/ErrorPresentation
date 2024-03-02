//
//  ErrorPresenter.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 15.02.2024.
//

import Foundation
import SwiftUI

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public final class ErrorPresenter: ObservableObject {

    @Published
    public private(set) var error: Error?

    public init(error: Error? = nil) {
        self.error = error
    }

    public func present(error: Error) {
        Task { @MainActor in
            if error.isCancelled {
                if self.error != nil {
                    self.error = nil
                }
            } else {
                self.error = error
            }
        }
    }

    public func clearError() {
        Task { @MainActor in
            guard self.error != nil else { return }
            self.error = nil
        }
    }
}

@available(iOS 15.0, tvOS 15.0, macOS 12, watchOS 8.0, *)
extension View {

    public func alert(with errorPresenter: ErrorPresenter) -> some View {
        self.alert(with: errorPresenter, title: errorPresenter.error.title) {
            DefaultErrorActions(error: $0)
        } message: {
            DefaultErrorMessage(error: $0)
        }
    }

    public func alert<S: StringProtocol, A: View, M: View>(
        with errorPresenter: ErrorPresenter,
        title: S,
        @ViewBuilder actions: (Error) -> A,
        @ViewBuilder message: (Error) -> M
    ) -> some View {
        self.alert(title, isPresented: errorPresenter.showUI, presenting: errorPresenter.error) {
            actions($0)
        } message: {
            message($0)
        }
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
fileprivate extension ErrorPresenter {

    var showUI: Binding<Bool> {
        Binding {
            self.error != nil
        } set: {
            guard $0 == false else { return }
            self.clearError()
        }
    }
}

private extension Optional where Wrapped: Error {
    var title: String {
        flatMap { ($0 as? LocalizedError)?.localizedDescription } ?? ""
    }
}

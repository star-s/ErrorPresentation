//
//  ErrorPresenter.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 15.02.2024.
//

import Foundation
import SwiftUI

public final class ErrorPresenter: ObservableObject {

    public private(set) var error: Error? {
        willSet {
            self.objectWillChange.send()
        }
    }

    public init(error: Error? = nil) {
        self.error = error
    }

    public func present(error: Error) {
        DispatchQueue.main.async {
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
        DispatchQueue.main.async {
            guard self.error != nil else { return }
            self.error = nil
        }
    }
}

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

private extension Optional where Wrapped: Error {
    var title: String {
        guard case .some(let wrapped) = self else {
            return ""
        }
        return (wrapped as? LocalizedError)?.errorDescription ?? wrapped.localizedDescription
    }
}

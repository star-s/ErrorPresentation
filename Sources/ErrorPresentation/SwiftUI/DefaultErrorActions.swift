//
//  DefaultErrorActions.swift
//  ErrorPresentation
//
//  Created by Sergey Starukhin on 16.02.2024.
//

import SwiftUI

@available(iOS 15.0, tvOS 15.0, macOS 12, watchOS 8.0, *)
public struct DefaultErrorActions: View {
    private struct ButtonVM: Identifiable {
        let id: Int
        let role: ButtonRole?
        let title: String

        let action: () -> Void
    }

    public var body: some View {
        ForEach(buttons) { vm in
            Button(role: vm.role, action: vm.action) {
                Text(vm.title)
            }
        }
    }

    private let buttons: [ButtonVM]

    public init(
        error: Error,
        emptyOptionsButtonTitle: String = "OK",
        resultHandler handler: ((_ recovered: Bool) -> Void)? = nil
    ) {
        var buttons: [ButtonVM] = []

        if let recoverableError = error as? RecoverableError {
            buttons = recoverableError.recoveryOptions.enumerated().reversed().map { (option) in
                ButtonVM(
                    id: option.offset,
                    role: option.offset == 0 ? .cancel : nil,
                    title: option.element
                ) {
                    recoverableError.attemptRecovery(optionIndex: option.offset) { recovered in
                        handler?(recovered)
                    }
                }
            }
        }
        if buttons.isEmpty {
            buttons.append(ButtonVM(
                id: 0,
                role: nil,
                title: emptyOptionsButtonTitle,
                action: {}
            ))
        }
        self.buttons = buttons
    }
}

@available(iOS 15.0, tvOS 15.0, macOS 12, watchOS 8.0, *)
#Preview {
    DefaultErrorActions(error: CocoaError(.featureUnsupported))
}

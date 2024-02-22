#if canImport(AppKit)
import AppKit

@objc
extension NSResponder {
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        (nextResponder ?? NSApplication.shared).presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
extension NSApplication {
    open override func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        let error = willPresentError(error)

        if error.isCancelled {
			handler(false)
			return
		}
        guard let window = windows.first(where: { $0.isKeyWindow && $0.isVisible }) else {
			handler(false)
            return
        }
		NSAlert(error: error).beginSheetModal(for: window) {
			guard let error = error as? RecoverableError else {
				handler(false)
				return
			}
			error.attemptRecovery(optionIndex: $0.recoveryOptionIndex, resultHandler: handler)
		}
    }
}

@objc
extension NSWindowController {
    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        guard let document = document as? NSDocument else {
            super.presentError(error, didPresentHandler: handler)
            return
        }
        document.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
extension NSDocumentController {
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        NSApplication.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
extension NSDocument {
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        NSDocumentController.shared.presentError(willPresentError(error), didPresentHandler: handler)
    }
}

private extension NSApplication.ModalResponse {
	var recoveryOptionIndex: Int { rawValue - 1000 }
}

#endif

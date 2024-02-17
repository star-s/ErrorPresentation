#if canImport(AppKit)
import AppKit

@objc
extension NSResponder {
    
    open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        (nextResponder ?? NSApplication.shared).presentError(willPresentError(error), didPresentHandler: handler)
    }
}

@objc
public protocol ErrorPresentationApplicationDelegate: NSApplicationDelegate {
	@objc
	optional func application(_ application: NSApplication, shouldPassErrorToNextResponder error: Error) -> Bool
	@objc
	optional func application(_ application: NSApplication, shouldSkipErrorPresentation error: Error) -> Bool
}

@objc
extension NSApplication {

	private typealias PresentationAnchor = NSWindow

    override open func presentError(_ error: Error, didPresentHandler handler: @escaping (_ recovered: Bool) -> Void) {
        let error = willPresentError(error)
		if let next = nextResponder, shouldPassErrorToNextResponder(error) {
			next.presentError(error, didPresentHandler: handler)
			return
		}
		if shouldSkipPresentingError(error) {
			handler(false)
			return
		}
        guard let anchor = presentationAnchor(for: error) else {
			handler(false)
            return
        }
		NSAlert(error: error).beginSheetModal(for: anchor) {
			guard let error = error as? RecoverableError else {
				handler(false)
				return
			}
			error.attemptRecovery(optionIndex: $0.recoveryOptionIndex, resultHandler: handler)
		}
    }

	private func presentationAnchor(for error: Error) -> PresentationAnchor? {
		windows.first(where: { $0.isKeyWindow && $0.isVisible })
	}

	private func shouldPassErrorToNextResponder(_ error: Error) -> Bool {
		guard let delegate = delegate as? ErrorPresentationApplicationDelegate else {
			return false
		}
		return delegate.application?(self, shouldPassErrorToNextResponder: error) ?? false
	}

	private func shouldSkipPresentingError(_ error: Error) -> Bool {
		guard let delegate = delegate as? ErrorPresentationApplicationDelegate else {
			return error.isCancelled
		}
		return delegate.application?(self, shouldSkipErrorPresentation: error) ?? error.isCancelled
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

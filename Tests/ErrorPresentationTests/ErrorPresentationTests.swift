import XCTest
@testable import ErrorPresentation

final class ErrorPresentationTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(ErrorPresentation().text, "Hello, World!")
        struct TestError: LocalizedError {
            var errorDescription: String? = "ErrorDescription"
            var failureReason: String? = "FailureReason"
            var recoverySuggestion: String? = "RecoverySuggestion"
        }
        struct SynchronousError: SyncRecoverableError {
            
            enum RecoveryOption: String, CaseIterable, ErrorRecoveryOption {
                case option1
                case option2
            }
            
            func attemptRecovery(option: RecoveryOption) -> Bool {
                switch option {
                case .option1:
                    return true
                case .option2:
                    return false
                }
            }
        }
        struct AsynchronousError: AsyncRecoverableError {
                        
            enum RecoveryOption: String, CaseIterable, ErrorRecoveryOption {
                case option1
                case option2
            }
            
            func attemptRecovery(option: RecoveryOption, resultHandler handler: @escaping (Bool) -> Void) {
                switch option {
                case .option1:
                    DispatchQueue.main.async {
                        handler(true)
                    }
                case .option2:
                    DispatchQueue.main.async {
                        handler(false)
                    }
                }
            }
        }
        //NSApplication.shared.presentError(TestError()) { (recovered) in
            //print(recovered)
        //}
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

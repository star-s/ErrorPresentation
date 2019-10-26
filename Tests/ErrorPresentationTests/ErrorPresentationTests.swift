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
        //NSApplication.shared.presentError(TestError()) { (recovered) in
            //print(recovered)
        //}
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

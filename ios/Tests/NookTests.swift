import XCTest
@testable import Nook

final class ResolveTests: XCTestCase {
    func testEmpty() { XCTAssertNil(resolve("  ")) }
    func testFullURL() { XCTAssertEqual(resolve("http://a.b/c")?.absoluteString, "http://a.b/c") }
    func testBareHost() { XCTAssertEqual(resolve("apple.com")?.absoluteString, "https://apple.com") }
    func testSearch() { XCTAssertEqual(resolve("hello world")?.absoluteString, "https://duckduckgo.com/?q=hello%20world") }
    func testWordIsSearch() { XCTAssertTrue(resolve("swift")!.absoluteString.hasPrefix("https://duckduckgo.com/")) }
}

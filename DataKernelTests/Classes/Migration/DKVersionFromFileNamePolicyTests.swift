import Foundation
import XCTest
@testable import DataKernel

class DKVersionFromFileNamePolicyTests: XCTestCase {
    let versionPolicy = DKVersionFromFileNamePolicy(prefix: "Model")
    let tmpUrl = URL(fileURLWithPath: NSTemporaryDirectory())

    func test() {
        XCTAssertEqual(
                try! versionPolicy.version(modelUrl: tmpUrl.appendingPathComponent("Model 31.mom")),
                31)
        XCTAssertEqual(
                try! versionPolicy.version(modelUrl: tmpUrl.appendingPathComponent("Model 2.mom")),
                2)
    }

    func test_defaultVersion() {
        XCTAssertEqual(
                try! versionPolicy.version(modelUrl: tmpUrl.appendingPathComponent("Model.mom")),
                1)
    }

    func test_wrongPrefixThrowsError() throws {
        do {
            let _ = try versionPolicy.version(modelUrl: tmpUrl.appendingPathComponent("AnotherTestModel 2.mom"))
            XCTFail("Must be error")
        } catch DKMigrationError.failedToGetVersionFromFilename {
        }
    }
}

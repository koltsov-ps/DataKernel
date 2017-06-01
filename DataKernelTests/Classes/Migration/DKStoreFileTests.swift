import Foundation
import XCTest
@testable import DataKernel

class DKStoreFileTests: XCTestCase {
    var dirUrl: URL!

    override func setUp() {
        dirUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("YxSQLiteFileTests")
        try! FileManager.default.removeAll(fromDirectory: dirUrl.path)
    }

    func testRemove() throws {
        let dbUrl = dirUrl.appendingPathComponent("db.sqlite")
        try TestData().generateModelV1(dbUrl: dbUrl)
        try DKStoreFile(url: dbUrl).remove()
        let actualFileNames = try FileManager.default.contentsOfDirectory(atPath: dirUrl.path)
        XCTAssertEqual(actualFileNames, [String]())
    }

    func testRemove_fileIsMissed() throws {
        let dbUrl = dirUrl.appendingPathComponent("db.sqlite")
        try DKStoreFile(url: dbUrl).remove()
    }
}

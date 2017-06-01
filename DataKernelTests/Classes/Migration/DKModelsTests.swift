import Foundation
import XCTest
@testable import DataKernel

class DKModelsTests: XCTestCase {
    func testFiles () {
        let bundle = Bundle(for: type(of: self))
        let models = DKModels(name: "Model", bundle: bundle)
        let fileNames = models.files.map {
            URL(fileURLWithPath: $0).lastPathComponent
        }.sorted()
        XCTAssertEqual(fileNames, ["Model 2.mom", "Model 3.mom", "Model.mom"])
    }
}

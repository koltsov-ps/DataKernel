import Foundation

extension FileManager {
    func removeAll(fromDirectory path: String) throws {
        try createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        let fileNames = try contentsOfDirectory(atPath: path)
        for fileName in fileNames {
            let fileUrl = URL(fileURLWithPath: path).appendingPathComponent(fileName)
            try removeItem(atPath: fileUrl.path)
        }
    }
}
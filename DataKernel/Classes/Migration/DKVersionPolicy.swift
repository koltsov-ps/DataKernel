import Foundation

public protocol DKVersionPolicy {
    func version(modelUrl: URL) throws -> Int
}

public struct DKVersionFromFileNamePolicy: DKVersionPolicy {
    public let prefix: String
    public func version(modelUrl: URL) throws -> Int {
        let filename = modelUrl.deletingPathExtension().lastPathComponent
        if filename.hasPrefix(prefix) {
            let suffix = filename.substring(from: filename.index(filename.startIndex, offsetBy: prefix.count))
            return Int(suffix.trimmingCharacters(in: CharacterSet.whitespaces)) ?? 1
        }
        throw DKMigrationError.versionNotFound(filename: filename)
    }
}

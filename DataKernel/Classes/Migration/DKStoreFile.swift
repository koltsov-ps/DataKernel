import Foundation

public struct DKStoreFile {
    public let url: URL

    public func remove() throws {
        let fileManager = FileManager.default
        for path in paths() {
            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(atPath: path)
            }
        }
    }

    public func move(to: URL) throws {
        try DKStoreFile(url: to).remove()
        let fileManager = FileManager.default
        let sourcePaths = paths()
        let targetPaths = paths(from: to)
        for i in 0..<sourcePaths.count {
            if fileManager.fileExists(atPath: sourcePaths[i]) {
                try fileManager.moveItem(atPath: sourcePaths[i], toPath: targetPaths[i])
            }
        }
    }

    private func paths(from url: URL? = nil) -> [String] {
        let path = (url ?? self.url).path
        return [path, path + "-shm", path + "-wal"]
    }
}

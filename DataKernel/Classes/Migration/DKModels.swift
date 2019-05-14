import Foundation
import CoreData

public struct DKModels {
    public let name: String
    public let bundle: Bundle

    public init(name: String, bundle: Bundle? = nil) {
        self.name = name
        self.bundle = bundle ?? Bundle.main
    }

    public var files: [String] {
        if let modelDir = self.bundle.path(forResource: self.name, ofType: "momd") {
            let modelDirName = NSURL(fileURLWithPath: modelDir, isDirectory: true).lastPathComponent
            return self.bundle.paths(forResourcesOfType: "mom", inDirectory: modelDirName)
        }
        return []
    }

    public func modelFile(name: String) throws -> String {
        guard let file = files.first(where: {
            name == NSURL(fileURLWithPath: $0, isDirectory: false).deletingPathExtension?.lastPathComponent
        }) else {
            throw DKMigrationError.modelNotFound(name: name, file: nil)
        }
        return file
    }

    public func model(name: String) throws -> NSManagedObjectModel {
        let file = try modelFile(name: name)
        guard let managedModel = NSManagedObjectModel(contentsOf: URL(fileURLWithPath: file))
            else {
                throw DKMigrationError.modelNotFound(name: name, file: file)
            }
        return managedModel
    }

    public func currentModel() throws -> NSManagedObjectModel {
        guard let modelPath = self.bundle.path(forResource: self.name, ofType: "momd") else {
            throw DKMigrationError.modelNotFound(name: self.name, file: nil)
        }
        if let model = NSManagedObjectModel(contentsOf: URL(fileURLWithPath: modelPath)) {
            return model
        } else {
            throw DKMigrationError.modelNotFound(name: self.name, file: modelPath)
        }
    }
}

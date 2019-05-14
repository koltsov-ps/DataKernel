import Foundation
import CoreData

public struct DKMigrationFactory {
    public let models: DKModels
    public let versionPolicy: DKVersionPolicy

    public func migrations(from: NSManagedObjectModel, to: NSManagedObjectModel) throws -> [DKMigration] {
        let modelFiles = try sortedModelFilesByVersionDesc()
        var migrations = [DKMigration]()
        var targetModel: NSManagedObjectModel? = nil
        for modelFile in modelFiles {
            guard let sourceModel = NSManagedObjectModel(contentsOf: URL(fileURLWithPath: modelFile)) else {
                throw DKMigrationError.failedToCreateModel(file: modelFile)
            }
            if let target = targetModel {
                let mapping = NSMappingModel(from: [models.bundle], forSourceModel: sourceModel, destinationModel: target)
                let migration = DKMigration(from: sourceModel, to: target, mapping: mapping)
                migrations.append(migration)
                if sourceModel == from {
                    return migrations.reversed()
                }
                targetModel = sourceModel
            } else {
                if sourceModel == to {
                    targetModel = sourceModel
                }
            }
        }
        throw DKMigrationError.failedToBuildMigrationPath
    }

    private func sortedModelFilesByVersionDesc() throws -> [String] {
        let fileAndVersion = try models.files.compactMap { (file: String) -> (file: String, version: Int)? in
            let modelFile = URL(fileURLWithPath: file)
            let version = try self.versionPolicy.version(modelUrl: modelFile)
            return (file: file, version: version)
        }
        return fileAndVersion
                .sorted(by: { $0.version > $1.version })
                .map { $0.file }
    }
}

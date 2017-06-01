import Foundation
import CoreData

public class DKProgressiveStoreLoader: DKStoreLoader {
    public let models: DKModels
    public let migrationFactory: DKMigrationFactory

    public init(models: DKModels, versionPolicy: DKVersionPolicy? = nil) {
        self.models = models
        let versionPolicy = versionPolicy ?? DKVersionFromFileNamePolicy(prefix: models.name)
        self.migrationFactory = DKMigrationFactory(models: models, versionPolicy: versionPolicy)
    }

    public func append(store: URL, ofType: String, to coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore {
        let fileExists = FileManager.default.fileExists(atPath: store.path)
        if fileExists {
            try migrateIfNeeded(store: store, ofType: ofType, targetModel: coordinator.managedObjectModel)
        }
        let options: [AnyHashable: Any] = [
            NSSQLitePragmasOption: [
                "journal_mode": "WAL"
            ]
        ]
        return try coordinator.addPersistentStore(
                ofType: ofType,
                configurationName: nil,
                at: store,
                options: options)
    }

    private func migrateIfNeeded(store: URL, ofType type: String, targetModel: NSManagedObjectModel) throws {
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: type, at: store, options: nil)
        if targetModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
            return
        }
        let storeModel = NSManagedObjectModel.mergedModel(from: [models.bundle], forStoreMetadata: metadata)!
        let migrations = try migrationFactory.migrations(from: storeModel, to: targetModel)
        for migration in migrations {
            try migration.apply(url: store, sourceStoreType: type, targetStoreType: type)
        }
    }
}

import Foundation
import CoreData

public struct DKMigration {
    public let from: NSManagedObjectModel
    public let to: NSManagedObjectModel
    public let mapping: NSMappingModel?

    public func apply(url: URL, sourceStoreType: String, targetStoreType: String) throws {
        if self.canPerformLightweightMigration(sourceStoreType: sourceStoreType, targetStoreType: targetStoreType) {
            try performLightweightMigration(url: url, storeType: sourceStoreType)
        } else {
            try performFullMigration(url: url, sourceStoreType: sourceStoreType, targetStoreType: targetStoreType)
        }
    }

    public func canPerformLightweightMigration(sourceStoreType: String, targetStoreType: String) -> Bool {
        if sourceStoreType != targetStoreType {
            return false
        }
        guard let mapping = mapping else {
            return true
        }
        for entityMapping in mapping.entityMappings {
            if entityMapping.mappingType == .customEntityMappingType {
                return false
            }
        }
        return true
    }

    public func performLightweightMigration(url: URL, storeType: String) throws {
        let options: [AnyHashable: Any] = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: mapping == nil
        ]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: to)
        try coordinator.addPersistentStore(
                ofType: storeType,
                configurationName: nil,
                at: url,
                options: options)
    }

    public func performFullMigration(url: URL, sourceStoreType: String, targetStoreType: String) throws {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let tempUrl = tempDir.appendingPathComponent("\(UUID().uuidString).tmp")
        let migrationManager = NSMigrationManager(
                sourceModel: from,
                destinationModel: to)
        try! migrationManager.migrateStore(
                from: url,
                sourceType: sourceStoreType,
                options: nil,
                with: mapping,
                toDestinationURL: tempUrl,
                destinationType: targetStoreType,
                destinationOptions: nil)
        try DKStoreFile(url: tempUrl).move(to: url)
    }
}

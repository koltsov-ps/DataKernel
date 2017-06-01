import Foundation
import CoreData

public struct DKStandardStoreLoader: DKStoreLoader {
    public let migrate: Bool
    public func append(store: URL, ofType: String, to coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore {
        let options = migrate ? OptionRef.migration : OptionRef.default
        return try coordinator.addPersistentStore(
                ofType: ofType,
                configurationName: nil,
                at: store,
                options: options.build())
    }
}

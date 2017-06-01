import Foundation
import CoreData

public protocol DKStoreLoader {
    func append(store: URL, ofType: String, to coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore
}

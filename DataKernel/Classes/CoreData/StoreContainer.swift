import Foundation
import CoreData

open class DKStoreContainer {
    let coordinator: NSPersistentStoreCoordinator
    let contexts: DKContexts
    let storeUrl: URL

    private var notificationToken: NSObjectProtocol?

    convenience init(modelName: String = "Model", bundle: Bundle? = nil) {
        guard let modelUrl = (bundle ?? Bundle.main).url(forResource: modelName, withExtension: "momd") else {
            fatalError("Model \(modelName) not found")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Initialization of NSManagedObjectModel failed with url \(modelUrl)")
        }
        self.init(model: model)
    }

    init(model: NSManagedObjectModel, contextsFactory: (NSPersistentStoreCoordinator) -> DKContexts) {
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        storeUrl = URL(fileURLWithPath: docDir).appendingPathComponent("Model.sqlite")
        contexts = contextsFactory(coordinator)
    }

    func addPersistentStore(ofType type: String, configurationName: String, at url: URL, with loader: DKStoreLoader, deleteStoreIfMigrationFails: Bool = true) throws {
        do {
            try _ = loader.append(store: url, ofType: type, to: coordinator)
        }
        catch let error as NSError {
            let isMigrationError = error.code == NSPersistentStoreIncompatibleVersionHashError || error.code == NSMigrationMissingSourceModelError
            guard isMigrationError && deleteStoreIfMigrationFails else {
                throw error
            }
            try DKStoreFile(url: url).remove()
            try _ = loader.append(store: url, ofType: type, to: coordinator)
        }
    }
}

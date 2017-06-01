import Foundation
import XCTest
import CoreData
@testable import DataKernel

class TestData {
    func generateModelV1(dbUrl: URL) throws {
        let bundle = Bundle(for: type(of: self))
        let models = DKModels(name: "Model", bundle: bundle)
        let context: NSManagedObjectContext? = try managedContext(url: dbUrl, model: models.model(name: "Model"))
        let testEntity = NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context!)
        testEntity.setValue("Ivanov Ivan", forKey: "name")
        try context!.save()
    }

    func generateAnotherTestModelV1(dbUrl: URL) throws {
        let bundle = Bundle(for: type(of: self))
        let models = DKModels(name: "AnotherTestModel", bundle: bundle)
        let context: NSManagedObjectContext? = try managedContext(url: dbUrl, model: models.model(name: "AnotherTestModel"))
        let testEntity = NSEntityDescription.insertNewObject(forEntityName: "FioEntity", into: context!)
        testEntity.setValue("Ivanov", forKey: "lastName")
        testEntity.setValue("Ivan", forKey: "firstName")
        try context!.save()
    }

    func managedContext(url: URL, model: NSManagedObjectModel) throws -> NSManagedObjectContext {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: url,
                options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
}

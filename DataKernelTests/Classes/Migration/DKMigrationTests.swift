import Foundation
import XCTest
import CoreData
@testable import DataKernel

class DKMigrationTests: XCTestCase {
    func testMigrationInPlaceWithMappingModel() throws {
        let dbUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("db.sqlite")
        try DKStoreFile(url: dbUrl).remove()

        let bundle = Bundle(for: type(of: self))
        let models = DKModels(name: "AnotherTestModel", bundle: bundle)

        try TestData().generateAnotherTestModelV1(dbUrl: dbUrl)

        let fromModel = models.model(name: "AnotherTestModel")
        let toModel = models.model(name: "AnotherTestModel 2")
        let migration = DKMigration(
                from: fromModel,
                to: toModel,
                mapping: NSMappingModel(from: [models.bundle], forSourceModel: fromModel, destinationModel: toModel))
        let storeType = NSSQLiteStoreType
        XCTAssertTrue(migration.canPerformLightweightMigration(sourceStoreType: storeType, targetStoreType: storeType))
        try migration.performLightweightMigration(url: dbUrl, storeType: storeType)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try models.currentModel())
        try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: dbUrl,
                options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        let request = NSFetchRequest<NSManagedObject>(entityName: "FioEntity")
        let fios = try context.fetch(request)
        XCTAssertEqual(fios.count, 1)
        let fio = fios.first!
        XCTAssertEqual(fio.value(forKey: "name") as? String, "Ivanov Ivan")
    }
}

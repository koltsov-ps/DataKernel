import Foundation
import XCTest
import CoreData
@testable import DataKernel

class DKProgressiveStoreLoaderTests: XCTestCase {
    func testMigrationFromV1ToV2() throws {
        let dbUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("db.sqlite")
        try DKStoreFile(url: dbUrl).remove()
        
        let testData = TestData()
        try testData.generateModelV1(dbUrl: dbUrl)
        
        let bundle = Bundle(for: type(of: self))
        let models = DKModels(name: "Model", bundle: bundle)
        
        let loader = DKProgressiveStoreLoader(models: models)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: models.model(name: "Model 2"))
        _ = try loader.append(store: dbUrl, ofType: NSSQLiteStoreType, to: coordinator)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        let request = NSFetchRequest<NSManagedObject>(entityName: "PersonEntity")
        let persons = try context.fetch(request)
        XCTAssertEqual(persons.count, 1)
        let person = persons.first!
        XCTAssertEqual(person.value(forKey: "fullName") as? String, "Ivanov Ivan")
    }
    
    func testMigrationFromV1ToV3() throws {
        let dbUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("db.sqlite")
        if FileManager.default.fileExists(atPath: dbUrl.path, isDirectory: nil) {
            try! FileManager.default.removeItem(at: dbUrl)
        }
        let bundle = Bundle(for: type(of: self))
        let models = DKModels(name: "Model", bundle: bundle)
        let testData = TestData()
        try testData.generateModelV1(dbUrl: dbUrl)

        let loader = DKProgressiveStoreLoader(models: models)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try models.currentModel())
        _ = try loader.append(store: dbUrl, ofType: NSSQLiteStoreType, to: coordinator)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        XCTAssertTrue(FileManager.default.fileExists(atPath: dbUrl.path))
        let request = NSFetchRequest<NSManagedObject>(entityName: "PersonEntity")
        let persons = try context.fetch(request)
        XCTAssertEqual(persons.count, 1)
        let person = persons.first!
        XCTAssertEqual(person.value(forKey: "lastName") as? String, "Ivanov")
        XCTAssertEqual(person.value(forKey: "firstName") as? String, "Ivan")
    }
}

//
// Created by p.koltsov on 09.26.2017.
// Copyright (c) 2017 mrdekk. All rights reserved.
//

import Foundation
import XCTest
import CoreData
@testable import DataKernel

class IndependentContextsTestCase: XCTestCase {

    let dbUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DataModel.sqlite")
    var coordinator: NSPersistentStoreCoordinator!
    var context: NSManagedObjectContext!

    func test() throws {
        try DKStoreFile(url: dbUrl).remove()
        try generate()

        let bundle = Bundle(for: type(of: self))
        let models = DKModels(name: "DataModel", bundle: bundle)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try models.currentModel())
        /*try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: dbUrl,
                options: nil)*/
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        let fetchRequest = NSFetchRequest<Car>(entityName: "Car")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Car.model), ascending: true)]
        let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        let results = FetchedResultControllerDelegateToArray<Car>()
        fetchController.delegate = results
        try fetchController.performFetch()
        results.items = fetchController.fetchedObjects!

        try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: dbUrl,
                options: nil)

        XCTAssertEqual(results.items.count, 3)
    }


    func testPersistentContainer() throws {
        if #available(iOS 10, *) {
            try DKStoreFile(url: dbUrl).remove()
            try generate()

            let bundle = Bundle(for: type(of: self))
            let models = DKModels(name: "DataModel", bundle: bundle)
            let container = NSPersistentContainer(name: "DataModel", managedObjectModel: try models.currentModel())
            let description = NSPersistentStoreDescription(url: dbUrl)
            description.type = NSSQLiteStoreType
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores(completionHandler: { _ in })

            let fetchRequest = NSFetchRequest<Car>(entityName: "Car")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Car.model), ascending: true)]
            let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            let results = FetchedResultControllerDelegateToArray<Car>()
            fetchController.delegate = results
            try fetchController.performFetch()
            results.items = fetchController.fetchedObjects!
            XCTAssertEqual(results.items.count, 3)
        }
    }

    private func generate() throws {
        let bundle = Bundle(for: type(of: self))
        let models = DKModels(name: "DataModel", bundle: bundle)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try models.currentModel())
        try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: dbUrl,
                options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        try generate(context: context)
    }

    private func generate(context: NSManagedObjectContext) throws {
        guard let car1 = NSEntityDescription.insertNewObject(forEntityName: "Car", into: context) as? Car else { return }
        car1.mark = "mark 1"
        car1.model = "model 1"
        guard let car2 = NSEntityDescription.insertNewObject(forEntityName: "Car", into: context) as? Car else { return }
        car2.mark = "mark 2"
        car2.model = "model 2"
        guard let car3 = NSEntityDescription.insertNewObject(forEntityName: "Car", into: context) as? Car else { return }
        car3.mark = "mark 3"
        car3.model = "model 3"
        try context.save()
    }
}


class FetchedResultControllerDelegateToArray<Item>: NSObject, NSFetchedResultsControllerDelegate {

    var items: [Item] = []

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("willChange")
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let item = anObject as? Item else { return }
        switch type {
            case .insert:
                guard let row = newIndexPath?.row else { return }
                if items.count == row {
                    items.append(item)
                } else {
                    items.insert(item, at: row)
                }
            case .update:
                guard let row = indexPath?.row ?? newIndexPath?.row else { return }
                items[row] = item
            case .delete:
                guard let row = indexPath?.row ?? newIndexPath?.row else { return }
                items.remove(at: row)
            case .move:
                guard let from = indexPath?.row,
                        let to = newIndexPath?.row else { return }
                items.remove(at: from)
                items.insert(item, at: to)
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("didChange")
    }
}
import Foundation
import CoreData

@objc(TestModelV2ToV3Mapping)
class TestModelV2ToV3Mapping: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        guard let name = sInstance.value(forKey: "fullName") as? String else {
            fatalError("Property 'fullName' not found")
        }
        let nameParts = name.components(separatedBy: " ")

        let dInstance = NSEntityDescription.insertNewObject(
                forEntityName: "PersonEntity",
                into: manager.destinationContext)
        dInstance.setValue(nameParts[0], forKey: "lastName")
        dInstance.setValue(nameParts[1], forKey: "firstName")
        manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
    }
}

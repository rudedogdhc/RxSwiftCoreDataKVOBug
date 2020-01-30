import Foundation
import CoreData

@objc(Person)
final class Person: NSManagedObject {
  @NSManaged var personName: String?
  @NSManaged public var pets: NSSet?

  @objc(addPetsObject:)
  @NSManaged public func addToPets(_ value: Pet)

  @objc(removePetsObject:)
  @NSManaged public func removeFromPets(_ value: Pet)

  @objc(addPets:)
  @NSManaged public func addToPets(_ values: NSSet)

  @objc(removePets:)
  @NSManaged public func removeFromPets(_ values: NSSet)
}

@objc(Pet)
final class Pet: NSManagedObject {
  @NSManaged var name: String?
}

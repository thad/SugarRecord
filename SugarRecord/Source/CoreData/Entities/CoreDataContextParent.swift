import Foundation
import CoreData

public enum CoreDataContextParent {
    case coordinator(NSPersistentStoreCoordinator)
    case context(NSManagedObjectContext)
}

import Foundation

public enum StorageType {
    case coreData
    case realm
}

typealias StorageOperation = ((_ context: Context, _ save: () -> Void) throws -> Void) throws -> Void

public protocol Storage: CustomStringConvertible, Requestable {
        
    var type: StorageType { get }
    var mainContext: Context! { get }
    var saveContext: Context! { get }
    var memoryContext: Context! { get }
    func removeStore() throws
    func operation<T>(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) throws -> T) throws -> T
    func fetch<T: Entity>(_ request: FetchRequest<T>) throws -> [T]
    
}

// MARK: - Storage extension (Fetching)

public extension Storage {

    func fetch<T: Entity>(_ request: FetchRequest<T>) throws -> [T] {
        return try self.mainContext.fetch(request)
    }
    
}

// MARK: - Storage extension

#if os(iOS) || os(tvOS) || os(watchOS)
public extension Storage {
    public func observable<T: NSManagedObject>(request: FetchRequest<T>) -> RequestObservable<T> where T:Equatable {
        return CoreDataObservable(request: request, context: self.mainContext as! NSManagedObjectContext)
    }
    
    func operation<T>(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) throws -> T) throws -> T {
        let context: NSManagedObjectContext = self.saveContext as! NSManagedObjectContext
        var _error: Error!
        
        var returnedObject: T!
        context.performAndWait {
            do {
                returnedObject = try operation(context, { () -> Void in
                    do {
                        try context.save()
                    }
                    catch {
                        _error = error
                    }
                    self.rootSavingContext.performAndWait({
                        if self.rootSavingContext.hasChanges {
                            do {
                                try self.rootSavingContext.save()
                            }
                            catch {
                                _error = error
                            }
                        }
                    })
                })
            } catch {
                _error = error
            }
        }
        if let error = _error {
            throw error
        }
        
        return returnedObject
    }
}
#endif

//
//  CoreDataStorage.swift
//  Carthage
//
//  Created by Gleb Oleinik on 2/21/17.
//  Copyright © 2017 in.caramba.SugarRecord. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Public

protocol CoreDataStorage: Storage {
    var rootSavingContext: NSManagedObjectContext! { get }
}

extension CoreDataStorage {
    
    public func operation<T>(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) throws -> T) throws -> T {
        let context: NSManagedObjectContext = (self.saveContext as? NSManagedObjectContext)!
        var _error: Error!
        
        var returnedObject: T!
        
        context.performAndWait {
            do {
                returnedObject = try operation(context, { () -> Void  in
                    do {
                        try context.save()
                    }
                    catch {
                        _error = error
                    }
                    if self.rootSavingContext.hasChanges {
                        self.rootSavingContext.performAndWait {
                            do {
                                try self.rootSavingContext.save()
                            }
                            catch {
                                _error = error
                            }
                        }
                    }
                })
            }
            catch {
                _error = error
            }
        }
        if let error = _error {
            throw error
        }
        
        return returnedObject
    }
    
    public func backgroundOperation(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) -> (), completion: @escaping (Error?) -> ()) {
        let context: NSManagedObjectContext = self.saveContext as! NSManagedObjectContext
        var _error: Error!
        context.perform {
            operation(context, { () -> Void in
                do {
                    try context.save()
                }
                catch {
                    _error = error
                }
                self.rootSavingContext.perform {
                    if self.rootSavingContext.hasChanges {
                        do {
                            try self.rootSavingContext.save()
                        }
                        catch {
                            _error = error
                        }
                    }
                    completion(_error)
                }
            })
        }
    }
    
    public func fetch<T: Entity>(_ request: FetchRequest<T>) throws -> [T] {
        return try self.mainContext.fetch(request)
    }
}

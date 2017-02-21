//
//  Storage+CoreData.swift
//  Carthage
//
//  Created by Gleb Oleinik on 2/21/17.
//  Copyright © 2017 in.caramba.SugarRecord. All rights reserved.
//

import Foundation
import CoreData


protocol CoreDataStorage: Storage {
    var rootSavingContext: NSManagedObjectContext! { get }
}

#if os(iOS) || os(tvOS) || os(watchOS)
extension CoreDataStorage {
    public func observable<T: NSManagedObject>(request: FetchRequest<T>) -> RequestObservable<T> where T:Equatable {
        return CoreDataObservable(request: request, context: self.mainContext as! NSManagedObjectContext)
    }
    
    public func operation<T>(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) throws -> T) throws -> T {
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

//
//  CoreDataMemoryStorage.swift
//  Carthage
//
//  Created by Gleb Oleinik on 2/16/17.
//  Copyright © 2017 in.caramba.SugarRecord. All rights reserved.
//

import Foundation
import CoreData

public class MemoryStorage: CoreDataBaseStorage, Storage {
    
    // MARK: - Storage conformance
    
    public var description: String {
        return "CoreDataMemoryStorage"
    }

    override public var saveContext: Context! {
        if let context = self._saveContext {
            return context
        }
        let _context = memoryContext as! NSManagedObjectContext
        _context.observe(inMainThread: true) { [weak self] (notification) -> Void in
            (self?.mainContext as? NSManagedObjectContext)?.mergeChanges(fromContextDidSave: notification as Notification)
        }
        self._saveContext = _context
        return _context
    }
    
    public func removeStore() throws {
        // noop
    }
    
    // MARK: - Init
    public init(model: CoreDataObjectModel) throws {
        super.init(model: model, versionController: VersionController())
        self.persistentStore = try cdInitializeStore(storeCoordinator: persistentStoreCoordinator)
    }
}

fileprivate func cdInitializeStore(storeCoordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore {
    var persistentStore: NSPersistentStore?
    var error: NSError?
    storeCoordinator.performAndWait({ () -> Void in
        do {
            persistentStore = try storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        }
        catch let _error as NSError {
            error = _error
        }
    })
    if let error = error {
        throw error
    }
    guard let store = persistentStore else {
        throw CoreDataError.persistenceStoreInitialization
    }
    
    return store
}

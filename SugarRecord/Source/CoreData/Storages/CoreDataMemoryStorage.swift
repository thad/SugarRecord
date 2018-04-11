//
//  CoreDataMemoryStorage.swift
//  Carthage
//
//  Created by Gleb Oleinik on 2/16/17.
//  Copyright © 2017 in.caramba.SugarRecord. All rights reserved.
//

import Foundation
import CoreData

#if os(iOS) || os(tvOS) || os(watchOS)
public class MemoryStorage: Storage {
    
    // MARK: - Attributes
    internal var objectModel: NSManagedObjectModel! = nil
    internal var persistentStore: NSPersistentStore! = nil
    internal var persistentStoreCoordinator: NSPersistentStoreCoordinator! = nil
    internal var rootSavingContext: NSManagedObjectContext! = nil
    
    
    // MARK: - Storage conformance
    
    public var description: String {
        return "CoreDataMemoryStorage"
    }
    
    public var type: StorageType = .coreData
    public var mainContext: Context!
    private var _saveContext: Context!
    public var saveContext: Context! {
        if let context = self._saveContext {
            return context
        }
        let _context = memoryContext
        _context.observe(inMainThread: true) { [weak self] (notification) -> Void in
            (self?.mainContext as? NSManagedObjectContext)?.mergeChanges(fromContextDidSave: notification as Notification)
        }
        self._saveContext = _context
        return _context
    }
    public var memoryContext: Context! {
        let _context =  cdContext(withParent: .context(self.rootSavingContext), concurrencyType: .privateQueueConcurrencyType, inMemory: true)
        return _context
    }
    
    public func removeStore() throws {
        // noop
    }
    
    // MARK: - Init
    public init(model: CoreDataObjectModel) throws {
        self.objectModel = model.model()!
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        self.persistentStore = try cdInitializeStore(storeCoordinator: persistentStoreCoordinator)
        self.rootSavingContext = cdContext(withParent: .coordinator(self.persistentStoreCoordinator), concurrencyType: .privateQueueConcurrencyType, inMemory: true)
        self.mainContext = cdContext(withParent: .context(self.rootSavingContext), concurrencyType: .mainQueueConcurrencyType, inMemory: true)
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
 

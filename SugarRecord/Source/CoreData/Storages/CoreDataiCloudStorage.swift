import Foundation
import CoreData

public class CoreDataiCloudStorage: CoreDataStorage {
    
    // MARK: - Attributes
    
    internal let store: CoreDataStore
    internal var objectModel: NSManagedObjectModel! = nil
    internal var persistentStore: NSPersistentStore! = nil
    internal var persistentStoreCoordinator: NSPersistentStoreCoordinator! = nil
    internal var rootSavingContext: NSManagedObjectContext! = nil
    
    
    // MARK: - Storage
    
    public var description: String {
        get {
            return "CoreDataiCloudStorage"
        }
    }
    public var type: StorageType = .coreData
    
    public var mainContext: Context!
    
    public var saveContext: Context! {
        get {
            let context = cdContext(withParent: .context(self.rootSavingContext), concurrencyType: .privateQueueConcurrencyType, inMemory: false)
            context.observe(inMainThread: true) { [weak self] (notification) -> Void in
                (self?.mainContext as? NSManagedObjectContext)?.mergeChanges(fromContextDidSave: notification as Notification)
            }
            return context
        }
    }
    
    public var memoryContext: Context! {
        get {
            let context =  cdContext(withParent: .context(self.rootSavingContext), concurrencyType: .privateQueueConcurrencyType, inMemory: true)
            return context
        }
    }
    
    public func removeStore() throws {
        try FileManager.default.removeItem(at: store.path() as URL)
    }
    
    
    // MARK: - Init
    
    public convenience init(model: CoreDataObjectModel, iCloud: CoreDataiCloudConfig) throws {
        try self.init(model: model, iCloud: iCloud, versionController: VersionController())
    }
    
    internal init(model: CoreDataObjectModel, iCloud: CoreDataiCloudConfig, versionController: VersionController) throws {
        self.objectModel = model.model()!
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let result = try! cdiCloudInitializeStore(storeCoordinator: persistentStoreCoordinator, iCloud: iCloud)
        self.store = result.0
        self.persistentStore = result.1
        self.rootSavingContext = cdContext(withParent: .coordinator(self.persistentStoreCoordinator), concurrencyType: .privateQueueConcurrencyType, inMemory: false)
        self.mainContext = cdContext(withParent: .context(self.rootSavingContext), concurrencyType: .mainQueueConcurrencyType, inMemory: false)
        self.observeiCloudChangesInCoordinator()
        #if DEBUG
            versionController.check()
        #endif
    }
    
    // MARK: - Private
    
    private func observeiCloudChangesInCoordinator() {
        NotificationCenter
            .default
            .addObserver(forName: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: self.persistentStoreCoordinator, queue: nil) { [weak self] (notification) -> Void in
                self?.rootSavingContext.perform {
                    self?.rootSavingContext.mergeChanges(fromContextDidSave: notification)
                }
        }
    }
    
}

internal func cdiCloudInitializeStore(storeCoordinator: NSPersistentStoreCoordinator, iCloud: CoreDataiCloudConfig) throws -> (CoreDataStore, NSPersistentStore?) {
    let storeURL = FileManager.default
        .url(forUbiquityContainerIdentifier: iCloud.ubiquitousContainerIdentifier)!
        .appendingPathComponent(iCloud.ubiquitousContentURL)
    var options = CoreDataOptions.migration.dict()
    options[NSPersistentStoreUbiquitousContentURLKey] = storeURL as AnyObject?
    options[NSPersistentStoreUbiquitousContentNameKey] = iCloud.ubiquitousContentName as AnyObject?
    let store = CoreDataStore.url(storeURL)
    return try (store, cdAddPersistentStore(store: store, storeCoordinator: storeCoordinator, options: options))
}

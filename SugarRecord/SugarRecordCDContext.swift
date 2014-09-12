//
//  SugarRecordCDContext.swift
//  SugarRecord
//
//  Created by Pedro Piñera Buendía on 11/09/14.
//  Copyright (c) 2014 SugarRecord. All rights reserved.
//

import Foundation
import CoreData

public class SugarRecordCDContext: SugarRecordContext
{
    let contextCD: NSManagedObjectContext
    
    init (context: NSManagedObjectContext)
    {
        self.contextCD = context
    }
    
    public func beginWritting()
    {
       // CD begin writting does nothing
    }
    
    public func endWritting()
    {
        var error: NSError?
        self.contextCD.save(&error)
        SugarRecord.handle(error)
        if error != nil {
            SugarRecordLogger.logLevelInfo.log("Context saved properly")
        }
    }
    
    public func insertObject(objectClass: NSObject.Type) -> AnyObject?
    {
        if (objectClass.isSubclassOfClass(NSManagedObject.Type)) {
            let error: NSError = NSError(domain: "The object you are trying to insert is not a NSManagedObject class", code: SugarRecordErrorCodes.UserError.toRaw(), userInfo: nil)
            SugarRecord.handle(error)
            return nil
        }
        let managedObjectClass: NSManagedObject.Type = objectClass as NSManagedObject.Type
        var object: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("", inManagedObjectContext: self.contextCD) as NSManagedObject
        return object
    }
    
    public func find(finder: SugarRecordFinder) -> [AnyObject]?
    {
        let objectClass: NSObject.Type = finder.objectClass!
        if (objectClass.isSubclassOfClass(NSManagedObject.Type)) {
            let error: NSError = NSError(domain: "The object you are trying to find is not a NSManagedObject class", code: SugarRecordErrorCodes.UserError.toRaw(), userInfo: nil)
            SugarRecord.handle(error)
            return nil
        }
        let managedObjectClass: NSManagedObject.Type = objectClass as NSManagedObject.Type
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        fetchRequest.sortDescriptors = finder.sortDescriptors
        fetchRequest.predicate = finder.predicate
        var error: NSError?
        let objects: [AnyObject]? = self.contextCD.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            SugarRecordLogger.logLevelInfo.log("Query executed. \(objects?.count) items found")
        }
        return objects
    }
    
    public func deleteObject(object: AnyObject) -> Bool
    {
        let managedObject: NSManagedObject? = object as? NSManagedObject
        if managedObject == nil {
            let error: NSError = NSError(domain: "The object you are trying to delete is not a NSManagedObject class", code: SugarRecordErrorCodes.UserError.toRaw(), userInfo: nil)
            SugarRecord.handle(error)
            return false
        }
        let objectInContext: NSManagedObject? = moveObject(managedObject!, inContext: contextCD)
        if objectInContext == nil  {
            let error: NSError = NSError(domain: "Imposible to remove object", code: SugarRecordErrorCodes.UserError.toRaw(), userInfo: nil)
            SugarRecord.handle(error)
            return false
        }
        SugarRecordLogger.logLevelInfo.log("Object removed from database")
        self.contextCD.deleteObject(managedObject!)
        return true
    }
    
    public func deleteObjects(objects: [AnyObject]) -> Bool
    {
        var objectsDeleted: Int = 0
        for object in objects {
            let objectDeleted: Bool = deleteObject(object)
            if objectDeleted {
                objectsDeleted++
            }
        }
        SugarRecordLogger.logLevelInfo.log("Deleted \(objectsDeleted) of \(objects.count)")
        return objectsDeleted == objects.count
    }
    
    
    //MARK - HELPER METHODS
    
    func moveObject(object: NSManagedObject, inContext context: NSManagedObjectContext) -> NSManagedObject?
    {
        var error: NSError?
        let objectInContext: NSManagedObject? = context.existingObjectWithID(object.objectID, error: &error)?
        if error != nil {
            let error: NSError = NSError(domain: "", code: SugarRecordErrorCodes.UserError.toRaw(), userInfo: nil)
            SugarRecord.handle(error)
            return nil
        }
        else {
            return objectInContext
        }
    }
}
//
//  CoreDataManager.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 2/27/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import CoreData

typealias GetPersistentContainerHandler = (_ container: NSPersistentContainer?) -> Void

/*
    This class is inteded to represent one instance of a core data stack.
    It will load an NSPersistentContainer with the specified name and provide 3 types of NSManagedObjectContext for operations.
 */
class CoreDataManager {
    
    // The main CoreData PersistentContainer
    private(set) var persistentContainer: NSPersistentContainer?
    
    // Context for executing tasks on a background queue. Should be the preferred choice. - ".privateQueueConcurencyType"
    private(set) var backgroundManagedObjectContext: NSManagedObjectContext?
    
    // Context for executing tasks on the main queue. Use this with good reason. Should always prefer backgroundManagedObjectContext.
    private(set) var mainManagedObjectContext: NSManagedObjectContext?
    
    // Context for executing tasks only in memory -- its parent is the background context, which does the disk write operation on a background queue
    // Should be preferred for frequent or rapid write operations.
    // WARNING: Changes in this context is NOT persisted to disk automatically and may be lost on unexpected app closure such as a crash event.
    // Must call "commitAllChangesToDisk()" to actually persist changes in this memory context to disk!
    private(set) lazy var memoryManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedObjectContext.parent = self.backgroundManagedObjectContext
        
        return managedObjectContext
    }()
    
    init(name: String, managedObjectModel: NSManagedObjectModel? = nil) {
        CoreDataManager.getPersistentContainer(name: name, managedObjectModel: managedObjectModel) { container in
            guard let container = container else { return }
            
            // Save the container itself
            self.persistentContainer = container
            
            // Save the main object context
            self.mainManagedObjectContext = container.viewContext
            self.mainManagedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            // Save a background context
            let backgroundContext = container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.backgroundManagedObjectContext = backgroundContext
            
            // Ensure the memory managed context's parent is the same background context
            self.memoryManagedObjectContext.parent = backgroundContext
        }
    }
    
    // Ensures all memory saved changes are pushed to its parent, which is a background ManagedObjectContext, which is then commited to disk on the background queue
    // This function must be called whenever changes in the memory context needs to be persisted to disk.
    func commitAllChangesToDisk() {
        guard let backgroundContext = self.backgroundManagedObjectContext else {
            return
        }
        
        if self.memoryManagedObjectContext.parent == nil {
            self.memoryManagedObjectContext.parent = backgroundContext
        }
        
        self.memoryManagedObjectContext.perform {
            do {
                if self.memoryManagedObjectContext.hasChanges {
                    try self.memoryManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
            backgroundContext.perform {
                do {
                    if backgroundContext.hasChanges {
                        try backgroundContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to Save Changes of Private Managed Object Context")
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            }
            
        }
    }
    
    static func getPersistentContainer(name: String, managedObjectModel: NSManagedObjectModel? = nil, handler: @escaping GetPersistentContainerHandler) {
        var container: NSPersistentContainer
        
        if let managedObjectModel = managedObjectModel {
            container = NSPersistentContainer(name: name, managedObjectModel: managedObjectModel)
        } else {
            container = NSPersistentContainer(name: name)
        }
        
        container.loadPersistentStores { (_, error) in
            guard error == nil else {
                handler(nil)
                return
            }
            
            return handler(container)
        }
    }
    
    static func getManagedObjectModel(name: String) -> NSManagedObjectModel? {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                return nil
        }
        
        return managedObjectModel
    }
}

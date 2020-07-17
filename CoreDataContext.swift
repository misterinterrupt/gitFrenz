//
//  CoreDataContext.swift
//  gitfrenz
//
//  Created by m interrupt on 7/15/20.
//  Copyright © 2020 m interrupt. All rights reserved.
//

import Foundation
import CoreData

class CoreDataContext {
    
    static let shared = CoreDataContext()
    
    lazy var persistentContainer: NSPersistentContainer! = {
        return NSPersistentContainer(name: "FrenzModel")
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    func load(done: @escaping () -> Void ) {
        self.persistentContainer.loadPersistentStores { description, error in
            if let err = error {
                fatalError("Could not load CoreData persistent store \(err)")
            }
            done()
        }
    }
    
    func saveChanges() {
        viewContext.performAndWait {
            do {
                if self.viewContext.hasChanges {
                    try self.viewContext.save()
                }
            } catch {
                print("Couldn't save changes to CoreData(view). \(error)")
            }
        }
        backgroundContext.performAndWait {
            do {
                if self.backgroundContext.hasChanges {
                    try self.backgroundContext.save()
                }
            } catch {
                print("Couldn't save changes to CoreData(background). \(error)")
            }
        }
    }
    
    
}

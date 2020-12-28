//
//  CoreDataStack.swift
//  ContactsApp
//
//  Created by Teacher on 21.12.2020.
//

import CoreData

class CoreDataStack {
    private let containerName: String

    init(containerName: String) {
        self.containerName = containerName
    }

    lazy var viewContext: NSManagedObjectContext = {
        container.viewContext
    }()

    func saveViewContext() {
        guard viewContext.hasChanges else { return }

        do {
            try viewContext.save()
        } catch {
            print("Save error: \(error)")
        }
    }

    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { description, error in
            if let error = error {
                assertionFailure("Could not load persistent store \(error)")
            }
        }
        return container
    }()
}

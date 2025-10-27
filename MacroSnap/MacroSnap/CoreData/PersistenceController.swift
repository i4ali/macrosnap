//
//  PersistenceController.swift
//  MacroSnap
//
//  Manages CoreData stack for offline caching
//

import CoreData

final class PersistenceController {
    // MARK: - Singleton
    static let shared = PersistenceController()

    // Preview instance for SwiftUI Previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Add sample data for previews
        for i in 0..<5 {
            let entry = MacroEntryEntity(context: viewContext)
            entry.id = UUID()
            entry.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            entry.protein = Double.random(in: 80...180)
            entry.carbs = Double.random(in: 150...250)
            entry.fat = Double.random(in: 40...70)
            entry.createdAt = Date()
            entry.updatedAt = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    // MARK: - Core Data Stack
    let container: NSPersistentContainer

    // MARK: - Initialization
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MacroSnap")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this error gracefully
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        // Automatically merge changes from parent
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save Context
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // MARK: - Background Context
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Delete All Data (for sign-out)
    func deleteAllData() {
        let entities = container.managedObjectModel.entities
        let context = container.viewContext

        for entity in entities {
            guard let entityName = entity.name else { continue }

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Failed to delete \(entityName): \(error)")
            }
        }
    }
}

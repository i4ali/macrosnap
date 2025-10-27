# MacroSnap CoreData Setup

This directory contains CoreData models for offline caching and data persistence.

## Overview

CoreData is used for:
- **Offline caching** - Store macro entries locally for offline access
- **Fast queries** - Quick retrieval of today's totals and recent entries
- **Sync queue** - Track entries that need to be synced to Supabase
- **Guest mode** - Store temporary data before sign-up

## Files

- `PersistenceController.swift` - CoreData stack manager
- `MacroEntryEntity+CoreDataClass.swift` - Macro entry entity logic
- `MacroEntryEntity+CoreDataProperties.swift` - Macro entry properties
- `GoalEntity+CoreDataClass.swift` - Goal entity logic
- `GoalEntity+CoreDataProperties.swift` - Goal properties
- `MacroSnap.xcdatamodeld` - CoreData model file (needs to be created in Xcode)

## Creating the CoreData Model in Xcode

Since `.xcdatamodeld` files are binary and must be created in Xcode, follow these steps:

### Step 1: Create the Data Model File

1. Open Xcode and navigate to your `MacroSnap` project
2. Right-click on the `CoreData` folder
3. Select **New File** → **Data Model**
4. Name it `MacroSnap.xcdatamodeld`
5. Click **Create**

### Step 2: Create MacroEntryEntity

1. Click the **+** button at the bottom to add a new entity
2. Name it `MacroEntryEntity`
3. Add the following attributes:

| Attribute | Type | Optional | Default |
|-----------|------|----------|---------|
| `id` | UUID | No | - |
| `date` | Date | No | - |
| `protein` | Double | No | 0 |
| `carbs` | Double | No | 0 |
| `fat` | Double | No | 0 |
| `notes` | String | Yes | - |
| `createdAt` | Date | No | - |
| `updatedAt` | Date | No | - |
| `needsSync` | Boolean | No | YES |
| `supabaseId` | String | Yes | - |

4. Set `id` as **Indexed**
5. Set `date` as **Indexed**
6. Set `needsSync` as **Indexed**

### Step 3: Create GoalEntity

1. Click the **+** button to add another entity
2. Name it `GoalEntity`
3. Add the following attributes:

| Attribute | Type | Optional | Default |
|-----------|------|----------|---------|
| `id` | UUID | No | - |
| `proteinGoal` | Double | No | 150 |
| `carbGoal` | Double | No | 200 |
| `fatGoal` | Double | No | 60 |
| `dayOfWeek` | Integer 16 | No | -1 |
| `createdAt` | Date | No | - |
| `updatedAt` | Date | No | - |
| `needsSync` | Boolean | No | YES |
| `supabaseId` | String | Yes | - |

4. Set `id` as **Indexed**
5. Set `dayOfWeek` as **Indexed**
6. Set `needsSync` as **Indexed**

### Step 4: Configure Codegen

1. Select `MacroEntryEntity`
2. In the Data Model Inspector (right panel), under **Class**:
   - Set **Codegen** to `Manual/None`
   - Set **Class** to `MacroEntryEntity`
   - Set **Module** to `MacroSnap`

3. Repeat for `GoalEntity`

## Usage

### Initialize CoreData

In your `MacroSnapApp.swift`:

```swift
import SwiftUI

@main
struct MacroSnapApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

### Create a Macro Entry

```swift
let context = PersistenceController.shared.container.viewContext
let entry = MacroEntryEntity(
    context: context,
    date: Date(),
    protein: 40,
    carbs: 30,
    fat: 10
)
PersistenceController.shared.save()
```

### Fetch Today's Entries

```swift
let context = PersistenceController.shared.container.viewContext
let entries = MacroEntryEntity.fetchEntries(for: Date(), context: context)
```

### Fetch Default Goal

```swift
let context = PersistenceController.shared.container.viewContext
let goal = GoalEntity.fetchDefaultGoal(context: context)
```

### Fetch Unsynced Entries

```swift
let context = PersistenceController.shared.container.viewContext
let unsyncedEntries = MacroEntryEntity.fetchUnsyncedEntries(context: context)
// Sync these to Supabase
```

## SwiftUI Integration

Use `@FetchRequest` in your SwiftUI views:

```swift
struct TodayView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MacroEntryEntity.createdAt, ascending: false)],
        predicate: NSPredicate(format: "date >= %@ AND date < %@",
                               Calendar.current.startOfDay(for: Date()) as NSDate,
                               Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate),
        animation: .default)
    private var entries: FetchedResults<MacroEntryEntity>

    var body: some View {
        // Use entries here
    }
}
```

## Sync Strategy

CoreData acts as the source of truth. The sync flow is:

1. **User creates entry** → Save to CoreData with `needsSync = true`
2. **Background sync** → Fetch entries where `needsSync = true`
3. **Upload to Supabase** → Send to Supabase API
4. **On success** → Set `needsSync = false` and store `supabaseId`
5. **On app launch** → Fetch recent entries from Supabase and update CoreData

## Data Cleanup

When user signs out:

```swift
PersistenceController.shared.deleteAllData()
```

## Testing

Use the preview instance for SwiftUI previews:

```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
```

## Performance Tips

- Use `@FetchRequest` for automatic UI updates
- Batch operations use `NSBatchDeleteRequest` and `NSBatchUpdateRequest`
- Use background contexts for heavy operations
- Keep fetch requests small and specific
- Use predicates and indexes for fast queries

## Troubleshooting

### "Entity not found" errors
- Make sure you created the entities in the `.xcdatamodeld` file
- Verify Codegen is set to `Manual/None`
- Check that Module is set correctly

### Sync conflicts
- Use `NSMergeByPropertyObjectTrumpMergePolicy` (already configured)
- Handle conflicts in the sync manager

### Migration issues
- For schema changes, create a new model version
- Implement lightweight or heavyweight migration as needed

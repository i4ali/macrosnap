# CoreData Model Migration Guide

## Important: Manual Xcode Steps Required

The CoreData property files have been updated, but you **MUST** also update the CoreData model file in Xcode to match.

### Steps to Update CoreData Model

1. **Open Xcode** and navigate to the MacroSnap project

2. **Open the CoreData model file**:
   - Find `MacroSnap.xcdatamodeld` in the project navigator
   - Click on it to open the model editor

3. **For MacroEntryEntity**:
   - Select `MacroEntryEntity` in the left panel
   - In the attributes section, **DELETE**:
     - `needsSync` (Boolean)
     - `supabaseId` (String)
   - **ADD** these new attributes:
     - `ckRecordID` (Type: String, Optional: YES)
     - `ckSystemFields` (Type: Binary Data, Optional: YES)

4. **For GoalEntity**:
   - Select `GoalEntity` in the left panel
   - In the attributes section, **DELETE**:
     - `needsSync` (Boolean)
     - `supabaseId` (String)
   - **ADD** these new attributes:
     - `ckRecordID` (Type: String, Optional: YES)
     - `ckSystemFields` (Type: Binary Data, Optional: YES)

5. **For PresetEntity**:
   - Select `PresetEntity` in the left panel
   - In the attributes section, **DELETE**:
     - `needsSync` (Boolean)
     - `supabaseId` (String)
     - `updatedAt` (Date) - if it exists
   - **ADD** these new attributes:
     - `ckRecordID` (Type: String, Optional: YES)
     - `ckSystemFields` (Type: Binary Data, Optional: YES)

6. **Create a new Model Version** (if you have existing data):
   - Go to Editor → Add Model Version
   - Name it something like "MacroSnap 2" or "MacroSnap_CloudKit"
   - Make it the current version: Select the `.xcdatamodeld` file in the project navigator, then in File Inspector, set "Current Model Version"

7. **Save the model** (⌘S)

8. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)

9. **Build the project** (⌘B) to verify no errors

## What Changed

### Old (Supabase) Fields:
- `needsSync: Boolean` - Tracked whether entity needed to be synced
- `supabaseId: String` - Stored Supabase database ID

### New (CloudKit) Fields:
- `ckRecordID: String` - Stores CloudKit record identifier
- `ckSystemFields: Data` - Stores encoded CloudKit system fields for change tracking

## Benefits of CloudKit Approach

1. **Offline-First**: CoreData is the source of truth
2. **Automatic Conflict Resolution**: CloudKit system fields enable smart merging
3. **No Server Costs**: Data stored in user's iCloud account
4. **Privacy**: Data stays in user's control

## Testing

After making these changes:

1. **Delete the app** from simulator/device (to start fresh)
2. **Run the app** and verify it launches without crashes
3. **Add some data** (entries, goals, presets)
4. **Check Settings** to see sync status
5. **Install on second device** (if available) to test sync

## Troubleshooting

If you see crashes related to CoreData:

1. **Check the model** - Ensure all attributes match the property files
2. **Delete app data** - Remove and reinstall the app
3. **Check migration** - If you have existing data, you may need a proper migration
4. **Reset simulator** - Product → Erase Content and Settings (iOS Simulator)

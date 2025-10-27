# Migration Plan: Supabase → CloudKit + Remove Authentication

## Overview
Switch from Supabase to CloudKit for user data storage and remove sign-in requirement. Users will access the app directly without authentication, with their data synced via iCloud.

## Phase 1: Remove Authentication & Guest Mode

### 1.1 Delete Authentication Files
- **Remove**: `screen0.md`
- **Remove**: `Views/Authentication/WelcomeView.swift`
- **Remove**: `Services/AuthenticationService.swift`
- **Remove**: `Views/Components/GuestBannerView.swift`
- **Remove**: `Views/Components/SignUpPromptSheet.swift`

### 1.2 Simplify App Entry Point
- **Modify**: `MacroSnapApp.swift`
  - Remove authentication routing
  - Start directly with `MainTabView()`
  - Remove `.unauthenticated` and `.guest` modes

### 1.3 Update AppState
- **Modify**: `Services/AppState.swift`
  - Remove `AppMode` enum (no longer needed)
  - Remove `authService`, `showGuestBanner`, `showSignUpPrompt`
  - Remove all guest mode logic
  - Keep `themeManager` but update for CloudKit

## Phase 2: Remove Supabase

### 2.1 Delete Supabase Files
- **Remove**: `supabase/` directory and all migrations
- **Remove**: `Services/SupabaseConfig.swift`
- **Remove**: `Services/SyncService.swift`

### 2.2 Update StoreManager
- **Modify**: `Services/StoreManager.swift`
  - Remove Supabase import and client
  - Remove `syncProStatusToSupabase()` method
  - Add UserDefaults storage for Pro status
  - Add CloudKit sync for Pro status (later phase)

### 2.3 Update ThemeManager
- **Modify**: `Services/ThemeManager.swift`
  - Remove Supabase sync methods
  - Use UserDefaults temporarily
  - Add CloudKit sync (later phase)

## Phase 3: Update CoreData for CloudKit

### 3.1 Modify CoreData Entities
- **Modify**: CoreData model (`.xcdatamodeld`)
  - **MacroEntryEntity**: Remove `supabaseId`, `needsSync`
  - **MacroEntryEntity**: Add `ckRecordID`, `ckSystemFields` (for CloudKit)
  - **GoalEntity**: Remove `supabaseId`, `needsSync`
  - **GoalEntity**: Add `ckRecordID`, `ckSystemFields`
  - **PresetEntity**: Remove `supabaseId`, `needsSync`
  - **PresetEntity**: Add `ckRecordID`, `ckSystemFields`

### 3.2 Update CoreData Classes
- **Modify**: `CoreData/*+CoreDataProperties.swift` files
  - Update properties to match new model
  - Remove Supabase-related methods

## Phase 4: Implement CloudKit Sync

### 4.1 Create CloudKit Infrastructure
- **Create**: `Services/CloudKitSyncService.swift`
  - Sync entries to/from CloudKit
  - Handle conflict resolution
  - Sync goals, presets, themes

- **Create**: `Models/CloudKitRecordable.swift`
  - Protocol for CloudKit sync
  - Extensions for converting CoreData ↔ CKRecord

- **Create**: `Utils/CloudKitConfig.swift`
  - CloudKit container configuration
  - Schema definitions

### 4.2 Update AppState with CloudKit
- **Modify**: `Services/AppState.swift`
  - Replace `syncService` with `cloudKitSyncService`
  - Add sync initialization on app launch
  - Handle CloudKit account status

## Phase 5: Update Settings

### 5.1 Modify SettingsView
- **Modify**: `Views/Settings/SettingsView.swift`
  - Remove "Account" section entirely
  - Remove sign-out functionality
  - Update "Sync" section to use CloudKit
  - Update goal saving to trigger CloudKit sync

## Phase 6: Update Documentation

### 6.1 Update Screen Specs
- **Modify**: `screen1.md`
  - Remove all guest banner references
  - Simplify to show main screen only

### 6.2 Update Roadmap
- **Modify**: `ROADMAP.md`
  - Change Phase 1 tasks:
    - ~~Supabase database schema~~ → CloudKit schema
    - ~~Authentication & Onboarding~~ → Remove entire section
    - ~~Guest Mode~~ → Remove entire section
    - Update "Data Sync" to reference CloudKit
  - Update all Supabase references throughout

### 6.3 Update Claude Instructions
- **Modify**: `CLAUDE.md`
  - Update tech stack: Remove Supabase, add CloudKit
  - Remove authentication workflow instructions
  - Update file structure to reflect changes

## Phase 7: Xcode Project Configuration

### 7.1 CloudKit Capability
- Enable CloudKit in project capabilities
- Configure CloudKit container ID: `iCloud.com.macrosnap.app`
- Set up CloudKit schema in CloudKit Console

### 7.2 Package Dependencies
- Remove Supabase Swift package
- No new packages needed (CloudKit is native)

### 7.3 App Groups (Optional)
- Configure for widget data sharing
- Group ID: `group.com.macrosnap.app`

## Implementation Order

1. ✅ Remove authentication files
2. ✅ Simplify app entry point
3. ✅ Remove Supabase dependencies
4. ✅ Update CoreData model
5. ✅ Create CloudKit sync service
6. ✅ Update settings UI
7. ✅ Update documentation
8. ✅ Configure Xcode project

## Testing Checklist

- [ ] App launches directly to Today screen
- [ ] Data persists locally in CoreData
- [ ] Data syncs to iCloud when online
- [ ] Works offline with local data
- [ ] Pro purchase still works
- [ ] Themes persist across devices
- [ ] Goals sync across devices
- [ ] Presets sync across devices

## Risk Mitigation

- **Data Loss**: Keep CoreData as local source of truth
- **Sync Conflicts**: Implement last-write-wins strategy
- **No iCloud Account**: App works fully offline, shows sync disabled message
- **Migration**: No migration needed (fresh start with CloudKit)

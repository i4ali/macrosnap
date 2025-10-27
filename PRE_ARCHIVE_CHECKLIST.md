# Pre-Archive Checklist for TestFlight/App Store

⚠️ **Complete these steps BEFORE running Product → Archive**

## 1. Remove Local StoreKit Configuration File

Your project currently includes `Configuration.storekit` which was used for local Xcode testing. This MUST be disabled for real IAP testing.

### Step 1A: Remove from Build (Xcode GUI)

1. **Open Xcode** → MacroSnap.xcodeproj
2. **Project Navigator** → Find `Configuration.storekit` (at root level)
3. **Right-click** Configuration.storekit
4. **Select:** "Remove Reference"
   - Or: Select it → Press Delete → Choose "Remove Reference"
   - ⚠️ Choose "Remove Reference" NOT "Move to Trash"
5. **The file stays on disk** but won't be included in builds

### Step 1B: Verify in Scheme Settings

1. **Product menu** → Scheme → Edit Scheme... (or ⌘<)
2. **Select:** Run (left sidebar)
3. **Click:** Options tab
4. **StoreKit Configuration:** Should show "None"
   - If it shows "Configuration.storekit", change to **None**
5. **Repeat for Archive:**
   - Select Archive (left sidebar)
   - Verify no StoreKit configuration
6. **Click:** Close

---

## 2. Verify Signing & Provisioning

### Step 2A: Check Signing Settings

1. **Project Navigator** → Click "MacroSnap" (top blue icon)
2. **Select:** MacroSnap target
3. **Signing & Capabilities** tab
4. **Verify:**
   - ✅ Automatically manage signing: **Checked**
   - ✅ Team: **2J2GCJ25MK** (your team)
   - ✅ Bundle Identifier: **MAHR.Partners.MacroSnap**
   - ✅ Provisioning Profile: Should say "Xcode Managed Profile"

### Step 2B: Check Entitlements

Ensure `MacroSnap.entitlements` includes:
- ✅ iCloud
- ✅ CloudKit
- ✅ In-App Purchase (should be automatic)

---

## 3. Verify Build Settings

### Step 3A: Check Archive Configuration

1. **Product** → Scheme → Edit Scheme...
2. **Select:** Archive (left sidebar)
3. **Build Configuration:** Should be **Release** (not Debug)
4. **Click:** Close

### Step 3B: Verify Version Numbers

Version is already correct, but verify:
- ✅ Marketing Version: **1.0** ✓
- ✅ Current Project Version: **1** ✓

---

## 4. Clean Build Folder

Before archiving:

1. **Product menu** → Hold **Option key**
2. **Clean Build Folder...** appears
3. Click it (or press ⌘⌥⇧K)
4. Wait for clean to complete

---

## 5. Select Correct Destination

Before archiving:

1. **Top toolbar** → Click device selector (next to scheme)
2. **Select:** "Any iOS Device (arm64)"
   - ⚠️ NOT a simulator
   - ⚠️ NOT a specific connected device (use generic)

---

## 6. Archive the Build

Now you're ready:

1. **Product menu** → Archive
2. **Wait 2-5 minutes** for build
3. **Organizer window** opens automatically
4. **Validate** the archive (optional but recommended):
   - Select your archive
   - Click "Validate App"
   - Choose "Automatically manage signing"
   - Wait for validation
   - Should show "Success"
5. **Click:** Distribute App
6. **Follow steps** in IAP_SETUP_GUIDE.md Part 3

---

## Common Issues

### Issue: "No accounts with App Store Connect access"

**Fix:**
1. Xcode → Settings... (⌘,)
2. Accounts tab
3. Add your Apple ID if missing
4. Select your account → Download Manual Profiles

### Issue: "Missing entitlements"

**Fix:**
1. Check MacroSnap.entitlements file exists
2. Verify it includes CloudKit and iCloud

### Issue: "Failed to create provisioning profile"

**Fix:**
1. App Store Connect → Certificates, IDs & Profiles
2. Verify Bundle ID is registered
3. Verify your Mac's certificate is valid
4. In Xcode: Signing & Capabilities → Uncheck & Recheck "Automatically manage"

### Issue: "Configuration.storekit file will interfere with IAP"

**Fix:** Follow Step 1 above to remove it from the build

---

## Quick Command Line Check

Verify your configuration:

```bash
# Check Bundle ID
plutil -p MacroSnap/MacroSnap.entitlements | grep application-identifier

# Check team
plutil -p MacroSnap/MacroSnap.entitlements | grep com.apple.developer.team-identifier

# Verify Configuration.storekit not in build products
# (Should show nothing after archiving)
find ~/Library/Developer/Xcode/Archives -name "Configuration.storekit"
```

---

## Checklist Summary

Before running Product → Archive:

- [ ] Configuration.storekit removed from build
- [ ] Scheme StoreKit Configuration set to "None"
- [ ] Signing set to Automatic
- [ ] Team: 2J2GCJ25MK
- [ ] Bundle ID: MAHR.Partners.MacroSnap
- [ ] Archive uses Release configuration
- [ ] Version: 1.0, Build: 1
- [ ] Build folder cleaned
- [ ] Destination: "Any iOS Device (arm64)"
- [ ] Ready to archive!

---

## After Successful Archive

Continue with **IAP_SETUP_GUIDE.md Part 3: Upload Build to TestFlight**

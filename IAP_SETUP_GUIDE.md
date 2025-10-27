# In-App Purchase Setup Guide - App Store Connect

This guide walks you through setting up **MacroSnap Pro** In-App Purchase in App Store Connect for real testing via TestFlight.

## Current IAP Configuration

**Product ID in Code:** `MAHR.Partners.MacroSnap.pro`
**Display Name:** MacroSnap Pro
**Price:** $4.99 USD
**Type:** Non-Consumable (one-time purchase)

---

## Prerequisites

Before you start:
- ✅ Apple Developer Account (paid membership)
- ✅ App created in App Store Connect
- ✅ Bundle ID registered: `MAHR.Partners.MacroSnap`
- ✅ Xcode archive build ready to upload

---

## Part 1: Create IAP in App Store Connect

### Step 1: Access In-App Purchases

1. **Go to App Store Connect:** https://appstoreconnect.apple.com
2. **Navigate to:** My Apps → MacroSnap
3. **Click:** Monetization → In-App Purchases (left sidebar)
4. **Click:** ➕ Create button

### Step 2: Configure IAP Product

#### A. Select Type
- **Choose:** Non-Consumable
- **Click:** Create

#### B. Reference Information
- **Reference Name:** MacroSnap Pro
  - _(This is internal only, users won't see it)_
- **Product ID:** `MAHR.Partners.MacroSnap.pro`
  - ⚠️ **CRITICAL:** This MUST match exactly what's in StoreManager.swift
  - Cannot be changed after creation
- **Click:** Create

#### C. Pricing
- **Click:** Add Pricing
- **Select:** Tier 5 (USD $4.99)
- **Review pricing** for other countries (automatically calculated)
- **Click:** Next
- **Availability:** All countries (or customize)
- **Click:** Done

#### D. App Store Information
You need to provide localized information for each language:

**For English (U.S.):**

1. **Display Name:** MacroSnap Pro
   - _What users see in the purchase screen_

2. **Description:**
```
Unlock all premium features:
• Unlimited daily entries
• Advanced analytics and insights
• Pro themes (Ocean, Mint, Sunset)
• Widget customization
• Streak tracking
• Priority support
```

3. **Review Screenshot/Note:**
   - **Not required for non-consumables**
   - You can skip this

**Add more languages if needed:**
- Click ➕ Add Language
- Repeat for other locales

#### E. Review Information (Optional)
- **Review Notes:** "One-time purchase to unlock all Pro features"
- **Screenshot:** Not required, but you can add upgrade screen screenshot

### Step 3: Submit for Review

1. **Review all information** you entered
2. **Click:** Save
3. **Status should show:** Ready to Submit
4. ⚠️ **IAP will be reviewed** when you submit your first app version

---

## Part 2: Create Sandbox Test Account

You need a sandbox account to test purchases without real money.

### Step 1: Access Sandbox Testers

1. **Go to:** App Store Connect → Users and Access
2. **Click:** Sandbox (left sidebar)
3. **Click:** ➕ (Add button)

### Step 2: Create Test Account

Fill in the form:
- **First Name:** Test
- **Last Name:** User
- **Email:** Create a NEW email that doesn't exist in Apple systems
  - Example: `macrosnap.test@gmail.com` (if you own this)
  - Or use: `macrosnap.test+001@yourdomain.com`
  - ⚠️ **Cannot be** an email used for any real Apple ID
- **Password:** Create a secure password (remember it!)
- **Country/Region:** United States (or your test region)
- **App Store Territory:** United States
- **Click:** Create

### Step 3: Save Credentials

Write down:
```
Sandbox Email: ________________
Sandbox Password: ________________
```

You'll need these to sign in on your test device.

---

## Part 3: Upload Build to TestFlight

IAP testing requires a real build uploaded to App Store Connect.

### Step 1: Create Archive Build

1. **Open Xcode** → MacroSnap.xcodeproj
2. **Select target:** Any iOS Device (Real Device or Generic)
   - ⚠️ Cannot archive with simulator selected
3. **Product menu** → Archive
4. **Wait for build** to complete (2-5 minutes)

### Step 2: Upload to App Store Connect

1. **Organizer window** should open automatically
   - If not: Window → Organizer → Archives
2. **Select your archive** → Click **Distribute App**
3. **Select:** App Store Connect → Upload
4. **Click:** Next
5. **Distribution options:**
   - ✅ App Thinning: All compatible devices
   - ✅ Rebuild from Bitcode: Yes (if available)
   - ✅ Include symbols: Yes
6. **Click:** Next
7. **Sign with:** Automatic signing
8. **Click:** Upload
9. **Wait 10-30 minutes** for processing

### Step 3: Enable TestFlight

1. **Go to:** App Store Connect → MacroSnap
2. **Click:** TestFlight tab
3. **Wait for build** to show "Ready to Test"
   - Processing can take 10-30 minutes
   - You'll get an email when ready
4. **Internal Testing:**
   - Click on your build version (1.0 build 1)
   - Click Internal Testing
   - Add yourself as internal tester
   - Click Save

---

## Part 4: Test IAP on Physical Device

### Step 1: Sign Out of Real Apple ID

⚠️ **IMPORTANT:** Test on a physical device (iPhone/iPad), not simulator

1. **On your iPhone/iPad:**
   - Settings → [Your Name] → Media & Purchases
   - Tap on Apple ID → Sign Out
   - ⚠️ Only sign out of **Media & Purchases**, NOT iCloud

### Step 2: Install TestFlight Build

1. **Install TestFlight** app from App Store (if not installed)
2. **Open App Store Connect** on computer
3. **Go to:** MacroSnap → TestFlight → Internal Testing
4. **Send invite** to your Apple ID email
5. **On iPhone/iPad:** Open invitation email
6. **Tap:** View in TestFlight
7. **Install** MacroSnap build

### Step 3: Test Purchase Flow

1. **Launch MacroSnap** from TestFlight
2. **Navigate to:** Settings → Upgrade to Pro
3. **Tap:** Purchase button
4. **Sign in prompt appears:**
   - Use your **Sandbox Test Account** email/password
   - ⚠️ NOT your real Apple ID
5. **Confirm purchase:**
   - Price shows as $4.99
   - Environment shows **[Sandbox]** at top
6. **Complete purchase:**
   - Tap Subscribe/Buy
   - May need Face ID/Touch ID (always succeeds in sandbox)
7. **Verify purchase:**
   - Pro features should unlock
   - Check Settings shows "Pro" badge
   - Verify Ocean, Mint, Sunset themes are available

### Step 4: Test Restore Purchases

1. **Settings → Scroll down** → Find "Restore Purchases" option
2. **Tap:** Restore Purchases
3. **Sign in** with same sandbox account
4. **Verify:** Pro features remain unlocked

### Step 5: Test Multiple Purchases

Sandbox allows buying same product multiple times:
1. Try purchasing again
2. Should show "You've already purchased this"
3. Or allow repurchase (depending on StoreKit logic)

---

## Part 5: Verify IAP Implementation

### Check these features work correctly:

- [ ] **Purchase Screen:**
  - Shows correct price ($4.99)
  - Shows product description
  - Purchase button works
  - Loading state during purchase
  - Success message after purchase

- [ ] **Pro Features Unlock:**
  - Ocean, Mint, Sunset themes become available
  - Settings shows "Pro" status
  - No more upgrade prompts
  - All premium features accessible

- [ ] **Persistence:**
  - Close and reopen app
  - Pro status persists
  - Features remain unlocked

- [ ] **Restore Purchases:**
  - Delete app
  - Reinstall from TestFlight
  - Open app
  - Tap "Restore Purchases"
  - Pro status restores successfully

- [ ] **Error Handling:**
  - Cancel purchase (tap outside modal)
  - App returns to normal state
  - Try with no internet connection
  - Verify appropriate error messages

---

## Part 6: Common Issues & Solutions

### Issue: "Cannot connect to App Store"

**Cause:** Not signed in with sandbox account
**Fix:**
1. Settings → Media & Purchases → Sign Out
2. Launch app and attempt purchase
3. Sign in with sandbox account when prompted

### Issue: "This In-App Purchase has already been purchased"

**Cause:** Sandbox account already bought it
**Fix:**
1. This is normal! It means it works
2. Create a new sandbox test account
3. Or test "Restore Purchases" instead

### Issue: "Product not found" or "No products available"

**Cause 1:** Build doesn't match App Store Connect app
**Fix:** Verify Bundle ID and Team ID match

**Cause 2:** IAP not approved yet
**Fix:** IAP must be "Ready to Submit" status

**Cause 3:** Product ID mismatch
**Fix:** Verify `MAHR.Partners.MacroSnap.pro` in both:
- App Store Connect IAP Product ID
- StoreManager.swift line 14

### Issue: Purchase succeeds but features don't unlock

**Cause:** Transaction not being processed
**Fix:** Check StoreManager.swift:
1. Verify `updatePurchaseState()` is called
2. Check `UserDefaults` is saving `isPro = true`
3. Ensure purchase state propagates to UI

### Issue: Sandbox account locked

**Cause:** Too many failed attempts
**Fix:** Create a new sandbox test account

---

## Part 7: Production Testing Checklist

Before submitting to App Review:

- [ ] IAP shows in App Store Connect
- [ ] IAP status: "Ready to Submit"
- [ ] Product ID matches code exactly
- [ ] Pricing is set correctly ($4.99 USD)
- [ ] Localized information complete
- [ ] Tested on physical device via TestFlight
- [ ] Purchase flow works smoothly
- [ ] Pro features unlock correctly
- [ ] Restore purchases works
- [ ] Error handling is user-friendly
- [ ] Receipt validation implemented (if needed)
- [ ] No crashes during purchase flow

---

## Part 8: Submit App for Review

Once IAP testing is complete:

1. **Return to App Store Connect** → MacroSnap
2. **Go to:** App Store tab (not TestFlight)
3. **Prepare for Submission:**
   - Add screenshots (already done ✅)
   - Add app description
   - Add privacy policy URL
   - Add support URL
   - Select IAP: Check "MacroSnap Pro"
4. **Submit for Review**

The IAP will be reviewed alongside your app.

---

## Part 9: Monitoring After Launch

### View IAP Performance:

1. **App Store Connect** → Analytics
2. **Sales and Trends** → In-App Purchases
3. **Metrics to track:**
   - Purchase conversion rate
   - Revenue
   - Failed transactions
   - Refund requests

### Handle Issues:

- **Failed transactions:** Check crash logs
- **Refund requests:** Contact user via support email
- **Reviews mentioning IAP:** Respond promptly

---

## Current Product ID Reference

For your records:

**StoreManager.swift (Line 14):**
```swift
enum ProductID: String, CaseIterable {
    case pro = "MAHR.Partners.MacroSnap.pro"
}
```

**App Store Connect:**
- Product ID: `MAHR.Partners.MacroSnap.pro`
- Price: $4.99 USD (Tier 5)
- Type: Non-Consumable

⚠️ **These MUST match exactly!**

---

## Quick Reference Commands

### Check Bundle ID:
```bash
cd MacroSnap
plutil -p MacroSnap/Info.plist | grep CFBundleIdentifier
```

### Create Archive (Command Line):
```bash
xcodebuild archive \
  -scheme MacroSnap \
  -archivePath ~/Desktop/MacroSnap.xcarchive \
  -configuration Release
```

### Upload Build (Command Line):
```bash
xcodebuild -exportArchive \
  -archivePath ~/Desktop/MacroSnap.xcarchive \
  -exportPath ~/Desktop/MacroSnap-IPA \
  -exportOptionsPlist ExportOptions.plist
```

---

## Support Resources

- **App Store Connect Help:** https://help.apple.com/app-store-connect/
- **StoreKit Documentation:** https://developer.apple.com/storekit/
- **IAP Best Practices:** https://developer.apple.com/app-store/in-app-purchase/
- **Sandbox Testing:** https://developer.apple.com/apple-pay/sandbox-testing/

---

## Next Steps

1. ✅ **Create IAP** in App Store Connect (Part 1)
2. ✅ **Create sandbox** test account (Part 2)
3. ✅ **Upload build** to TestFlight (Part 3)
4. ✅ **Test purchase** on physical device (Part 4)
5. ✅ **Verify** all features work (Part 5)
6. ✅ **Submit** app for review (Part 8)

---

**Need help?** Check the "Common Issues" section or reach out with specific error messages.

**Ready to submit?** Make sure you've completed the Production Testing Checklist in Part 7!

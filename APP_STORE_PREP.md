# MacroSnap - App Store Preparation Checklist

This document outlines everything needed to successfully submit MacroSnap to the App Store.

---

## 🎯 **Phase 1: Pre-Submission Requirements**

### 1. App Icon
- [ ] **1024x1024 App Store icon** (required, no transparency, no rounded corners)
- [ ] Test icon on device in all sizes (60pt, 76pt, 83.5pt, 1024pt)
- [ ] Ensure icon looks good on dark/light backgrounds

**Resources:**
- App icon should be in `MacroSnap/Assets.xcassets/AppIcon.appiconset/`
- Use [App Icon Generator](https://www.appicon.co/) for all sizes

### 2. App Store Screenshots (REQUIRED)
Need screenshots for these device sizes:
- [ ] **6.7" display** (iPhone 15 Pro Max, 14 Pro Max, 13 Pro Max, 12 Pro Max)
  - Resolution: 1290 x 2796 pixels
  - Portrait orientation
  - 2-10 screenshots required

- [ ] **6.5" display** (iPhone 11 Pro Max, XS Max)
  - Resolution: 1242 x 2688 pixels
  - Portrait orientation
  - 2-10 screenshots required

**Recommended Screenshots:**
1. Today screen with progress rings
2. Quick Log modal
3. History calendar view
4. Analytics (week/month view)
5. Settings with Pro badge
6. Pro features showcase

**Tips:**
- Use iOS Simulator to capture perfect screenshots
- Add text overlays highlighting key features
- Use consistent theme (Dark Grey or Slate)
- Show realistic data, not empty states

### 3. App Store Metadata

#### App Name
- [ ] Decide on final name: **"MacroSnap"** or **"MacroSnap: Simple Macro Tracker"**
- [ ] Keep under 30 characters
- [ ] Check availability on App Store

#### Subtitle (30 characters max)
- [ ] Example: "Track Macros, Hit Your Goals"
- [ ] Must be concise and descriptive

#### Keywords (100 characters max, comma-separated)
- [ ] Example: "macro,macros,tracking,nutrition,fitness,diet,protein,carbs,fat,calories,goals,health"
- [ ] Research competitor keywords
- [ ] Use all 100 characters

#### Description (4000 characters max)
```markdown
# Short Description (First 170 characters - shown in search)
Track your macros with zero friction. Simple, fast, and beautiful macro tracking designed for people who actually track their nutrition daily.

# Full Description
MacroSnap is the fastest way to track your daily macros. No bloat. No social features. Just you, your goals, and perfect execution.

**WHY MACROSNAP?**

✓ Lightning Fast - Log macros in 3 seconds
✓ Offline First - Works without internet, syncs via iCloud
✓ Privacy Focused - Your data stays in YOUR iCloud, never on our servers
✓ No Subscriptions - One-time purchase for Pro features
✓ iOS Native - Designed specifically for iPhone, not a web app port

**FREE FEATURES**

• Beautiful progress rings showing daily macro targets
• Quick log with custom numeric keypad
• 7-day history with calendar view
• Daily streak counter
• Basic weekly analytics
• Four free themes (System, Dark, Dark Grey, Slate)
• iCloud sync across all your devices
• Siri Shortcuts support

**PRO FEATURES ($4.99 one-time)**

• Unlimited history (access all past entries)
• Notes & meal names for each entry
• Macro presets library (save favorite meals)
• Custom daily goals (different goals per day of week)
• Week & month analytics with charts
• Export data as CSV
• Premium themes (Mint, Sunset, Ocean)
• Lock screen widgets (coming soon)

**PERFECT FOR:**

• Bodybuilders tracking cutting/bulking phases
• Athletes optimizing performance nutrition
• Anyone doing flexible dieting (IIFYM)
• Fitness enthusiasts hitting specific macro targets

**NO BLOAT PHILOSOPHY**

We don't do:
- Recipe databases (you know what you eat)
- Social features (your nutrition is personal)
- Food photos (adds friction)
- Exercise tracking (use other apps for that)

We do ONE thing exceptionally well: macro tracking.

**PRIVACY FIRST**

• No account required
• No email collection
• No analytics or tracking
• Your data syncs via YOUR iCloud account
• We never see your data

Download MacroSnap and start hitting your macro goals today.
```

#### Promotional Text (170 characters, updatable anytime)
- [ ] Example: "New: Siri Shortcuts support! Log macros with your voice. Plus bug fixes and performance improvements."

#### Support URL
- [ ] Create support page: `https://macrosnap.app/support`
- [ ] Or use: `mailto:support@macrosnap.app`

#### Marketing URL (optional)
- [ ] Main website: `https://macrosnap.app`

#### Privacy Policy URL (REQUIRED)
- [ ] Create privacy policy page: `https://macrosnap.app/privacy`
- [ ] Must be publicly accessible before submission

### 4. App Store Connect Configuration

#### Category (Primary & Secondary)
- [ ] **Primary**: Health & Fitness
- [ ] **Secondary**: Food & Drink (optional)

#### Age Rating
- [ ] Complete questionnaire
- [ ] Expected: **4+ (No objectionable content)**

#### Pricing
- [ ] **Free** with in-app purchase
- [ ] Make available in all territories (or select specific countries)

#### In-App Purchase Setup
- [ ] Create IAP in App Store Connect: **"MacroSnap Pro"**
- [ ] Type: **Non-Consumable**
- [ ] Reference Name: `macrosnap_pro`
- [ ] Product ID: `com.yourdomain.macrosnap.pro`
- [ ] Price: **$4.99 USD** (Tier 5)
- [ ] Localized title: "MacroSnap Pro"
- [ ] Localized description: "Unlock unlimited history, notes, presets, themes, analytics, and export."
- [ ] Screenshot: Show Pro features
- [ ] Review information: Explain how to test Pro features

---

## 🛠️ **Phase 2: Code & Build Preparation**

### 1. Info.plist Configuration
- [ ] Check `CFBundleDisplayName` (app name shown on home screen)
- [ ] Verify `CFBundleShortVersionString` (version: 1.0.0)
- [ ] Verify `CFBundleVersion` (build number: 1)
- [ ] Add `NSUserTrackingUsageDescription` (if using any tracking - we're not)
- [ ] Add `CloudKit` capability description (already done)
- [ ] Add `Notifications` capability description (already done)

### 2. Xcode Project Settings
- [ ] Set **Team** in Signing & Capabilities
- [ ] Set **Bundle Identifier**: `com.yourdomain.macrosnap`
- [ ] Enable **Automatic Signing**
- [ ] Verify **Capabilities**:
  - iCloud (CloudKit)
  - Push Notifications
  - Background Modes (Remote notifications)
  - Siri (App Intents)
- [ ] Set **Deployment Target**: iOS 17.0 minimum
- [ ] Set **Supported Devices**: iPhone only (or Universal if iPad ready)
- [ ] Set **Supported Orientations**: Portrait only

### 3. Build Configuration
- [ ] Set **Release** scheme for archive
- [ ] Enable **Bitcode**: No (deprecated)
- [ ] **Optimization Level**: Fastest, Smallest [-Os]
- [ ] **Strip Debug Symbols**: Yes (Release only)

### 4. CloudKit Setup
- [ ] Verify CloudKit container is production-ready
- [ ] Test CloudKit sync on clean device
- [ ] Ensure CloudKit schema is deployed to production
- [ ] Test with multiple devices to verify sync

### 5. StoreKit Configuration
- [ ] Test IAP with sandbox account
- [ ] Verify purchase flow works
- [ ] Test restore purchases
- [ ] Test purchase on clean device (no prior purchases)

---

## ✅ **Phase 3: Quality Assurance**

### Polish & Bug Fixes (Before Submission)
- [ ] Test all screens on iPhone SE (smallest screen)
- [ ] Test on iPhone 15 Pro Max (largest screen)
- [ ] Test in Light mode AND Dark mode
- [ ] Test all themes (ensure readability)
- [ ] Verify all Pro features are locked for free users
- [ ] Test Pro purchase flow end-to-end
- [ ] Verify CloudKit sync works offline → online
- [ ] Test notifications and badge clearing
- [ ] Test Siri shortcuts
- [ ] Check for any crashes (use Xcode Organizer)
- [ ] Verify no console errors or warnings

### Empty States
- [ ] Today screen with no entries
- [ ] History with no data
- [ ] Preset library when empty
- [ ] Custom daily goals when empty

### Error Handling
- [ ] Network errors (airplane mode)
- [ ] CloudKit quota exceeded
- [ ] Invalid input in Quick Log
- [ ] IAP failure scenarios
- [ ] Notifications permission denied

### Accessibility (Basic)
- [ ] Test with VoiceOver (basic navigation)
- [ ] Test with Dynamic Type (Large Text)
- [ ] Ensure contrast ratios are sufficient
- [ ] Add accessibility labels to key UI elements

### Performance
- [ ] App launches in <2 seconds
- [ ] Quick Log opens instantly
- [ ] No lag when scrolling history
- [ ] Smooth animations (60fps)

---

## 📦 **Phase 4: Build & Upload**

### 1. Create Archive
```bash
# In Xcode:
1. Select "Any iOS Device (arm64)" as destination
2. Product → Archive
3. Wait for archive to complete
4. Xcode Organizer opens automatically
```

### 2. Distribute App
```bash
# In Xcode Organizer:
1. Select your archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Select "Upload"
5. Follow prompts (re-sign if needed)
6. Upload completes (takes 5-15 minutes)
```

### 3. Verify Upload
- [ ] Open App Store Connect
- [ ] Go to "My Apps" → MacroSnap
- [ ] Check "Activity" tab for build status
- [ ] Wait for "Processing" → "Ready to Submit"
- [ ] Usually takes 10-30 minutes

---

## 🚀 **Phase 5: App Store Connect Submission**

### 1. Add Build to Version
- [ ] Select version (1.0)
- [ ] Click "Select a build before you submit your app"
- [ ] Choose the uploaded build
- [ ] Wait for Apple to process (if still processing)

### 2. Complete App Information
- [ ] Upload all screenshots (6.7", 6.5")
- [ ] Add promotional text
- [ ] Add description
- [ ] Add keywords
- [ ] Set support URL
- [ ] Set privacy policy URL
- [ ] Add marketing URL (optional)

### 3. Review Information
- [ ] Add **demo account** (if app requires login - we don't)
- [ ] Add **notes for reviewer**:
  ```
  MacroSnap is a simple macro tracking app with iCloud sync.

  How to test:
  1. The app works immediately - no login required
  2. Add a macro entry using the "+" button
  3. View history by tapping the History tab
  4. Test Pro features: Tap "Upgrade to Pro" in Settings
  5. Use the sandbox IAP account to purchase Pro

  Pro features to test:
  - Unlimited history (free users limited to 7 days)
  - Notes field in Quick Log
  - Macro presets library
  - Custom daily goals (different goals per day)
  - Export data

  CloudKit:
  - The app uses CloudKit for iCloud sync
  - Data syncs automatically across devices
  - All data is stored in the user's iCloud account

  Thank you for reviewing!
  ```

### 4. Age Rating
- [ ] Complete questionnaire
- [ ] Confirm 4+ rating

### 5. Submit for Review
- [ ] Review all information
- [ ] Check "Manually release this version" (or auto-release)
- [ ] Click "Submit for Review"
- [ ] Confirm submission

---

## ⏱️ **Phase 6: Post-Submission**

### During Review (1-3 days typically)
- [ ] Monitor App Store Connect for status updates
- [ ] Check email for any messages from Apple
- [ ] Be ready to respond quickly if rejected

### If Approved
- [ ] App status changes to "Ready for Sale"
- [ ] Check App Store to verify listing looks correct
- [ ] Download app from App Store to test
- [ ] Verify IAP works in production
- [ ] Prepare launch announcement

### If Rejected
- [ ] Read rejection reason carefully
- [ ] Fix the issue
- [ ] Upload new build (increment build number)
- [ ] Re-submit with explanation

### Common Rejection Reasons & Solutions
1. **Guideline 2.1 - App Completeness**
   - Issue: App crashes or has broken features
   - Fix: Test thoroughly before submission

2. **Guideline 3.1.1 - In-App Purchase**
   - Issue: IAP not configured correctly
   - Fix: Verify StoreKit config, test with sandbox

3. **Guideline 5.1.1 - Privacy**
   - Issue: Privacy policy missing or inadequate
   - Fix: Ensure privacy policy URL is working and comprehensive

4. **Guideline 4.0 - Design**
   - Issue: App doesn't feel "finished"
   - Fix: Polish UI, add proper empty states, improve error messages

---

## 📋 **Phase 7: Pre-Launch Checklist**

### Marketing Assets
- [ ] App Store screenshots (done above)
- [ ] Promotional images for social media
- [ ] Demo video (optional but recommended)
- [ ] Product Hunt thumbnail (1200x630)
- [ ] Twitter/X announcement thread draft

### Website
- [ ] Create landing page: `macrosnap.app`
- [ ] Add privacy policy page: `macrosnap.app/privacy`
- [ ] Add support page: `macrosnap.app/support`
- [ ] Add App Store badge/link
- [ ] Add email capture for updates (optional)

### Support Infrastructure
- [ ] Setup support email: `support@macrosnap.app`
- [ ] Create email templates for common questions
- [ ] Prepare FAQ document
- [ ] Setup email forwarding/monitoring

### Analytics (Optional - Keep Privacy-Friendly)
- [ ] Setup basic crash reporting (Sentry, Crashlytics)
- [ ] Setup app analytics (privacy-friendly only)
- [ ] Track: downloads, DAU, MAU, Pro conversion

---

## 🎉 **Phase 8: Launch Day**

### Pre-Launch (Day Before)
- [ ] Verify app is live on App Store
- [ ] Test download and install
- [ ] Test Pro purchase in production
- [ ] Prepare social media posts
- [ ] Prepare email to beta testers (if any)

### Launch Day
- [ ] Post to Product Hunt
- [ ] Post on Reddit:
  - r/fitness
  - r/bodybuilding
  - r/MacrosFirst
  - r/SideProject
- [ ] Post on Twitter/X with demo video
- [ ] Email beta testers
- [ ] Post in relevant Discord/Slack communities
- [ ] Share on personal network

### Post-Launch Monitoring (First Week)
- [ ] Monitor crash reports daily
- [ ] Respond to App Store reviews
- [ ] Track downloads and revenue
- [ ] Gather user feedback
- [ ] Prepare hot fixes if needed
- [ ] Monitor support email

---

## 🔧 **Quick Reference: Xcode Commands**

### Archive for App Store
```bash
1. Clean Build Folder: Cmd + Shift + K
2. Select "Any iOS Device (arm64)"
3. Product → Archive
4. Wait for completion
5. Distribute → App Store Connect → Upload
```

### Increment Build Number
```bash
# Before each new upload:
1. Select project in Xcode
2. Go to Target → General
3. Increment "Build" number (1 → 2 → 3...)
4. Version stays same (1.0.0) until feature releases
```

### Test IAP in Sandbox
```bash
1. Settings → App Store → Sandbox Account
2. Add test account from App Store Connect
3. Run app in Debug mode
4. Test purchase flow
5. Verify purchase completes
```

---

## 📞 **Support & Resources**

### Apple Documentation
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)

### Community
- [r/iOSProgramming](https://reddit.com/r/iOSProgramming)
- [Swift Forums](https://forums.swift.org)
- [Apple Developer Forums](https://developer.apple.com/forums/)

---

## ✅ **Current Status**

**Completed:**
- ✅ Core app functionality
- ✅ iCloud sync via CloudKit
- ✅ Pro features with StoreKit 2
- ✅ Onboarding flow
- ✅ Notifications and reminders
- ✅ Siri Shortcuts
- ✅ Multiple themes
- ✅ History and analytics

**Remaining:**
- ⏳ App icon creation
- ⏳ Screenshots for App Store
- ⏳ Privacy policy page
- ⏳ Support infrastructure
- ⏳ App Store metadata
- ⏳ Polish (empty states, animations, haptics)
- ⏳ Testing (accessibility, error handling)
- ⏳ Build and upload

**Estimated Time to Submission:** 3-5 days (with focused effort)

---

**Last Updated:** 2025-10-27

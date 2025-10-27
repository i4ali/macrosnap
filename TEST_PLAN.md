# MacroSnap Manual Test Plan

**Version**: 1.0
**Last Updated**: 2025-10-26
**Target Build**: Pre-Launch

---

## Test Environment Setup

### Prerequisites
- [ ] Fresh app install (delete app if already installed)
- [ ] iOS Simulator (iPhone 16 recommended) OR physical device
- [ ] iCloud account signed in (for sync tests)
- [ ] Note device name for multi-device sync tests

---

## 1. First Launch & Onboarding

### Test 1.1: First Launch Experience
**Steps:**
1. Launch app for the first time
2. Observe onboarding screen

**Expected Results:**
- [ ] Onboarding appears automatically (not main app)
- [ ] Background is dark grey (#212123), not pure black
- [ ] "Welcome to MacroSnap" page shows with animated rings
- [ ] Rings continuously fill and unfill (breathing animation)
- [ ] Three concentric rings: Blue (outer), Orange (middle), Green (inner)
- [ ] Skip button visible in top-right corner

### Test 1.2: Onboarding Navigation
**Steps:**
1. Swipe left through all onboarding pages
2. Count total pages
3. Read each page title

**Expected Results:**
- [ ] 6 total pages (Welcome, Quick Logging, Use Your Voice, Set Goals, Track Progress, Unlock Pro)
- [ ] Each page has animated ring that fills/unfills
- [ ] Each page has clear title and description
- [ ] Swipe gesture works smoothly
- [ ] Page indicator dots visible at bottom

### Test 1.3: Complete Onboarding
**Steps:**
1. Navigate to last page (Unlock Pro)
2. Tap "Get Started" button

**Expected Results:**
- [ ] Onboarding dismisses
- [ ] Main app appears (Today tab)
- [ ] Never shows onboarding again on subsequent launches

### Test 1.4: Skip Onboarding
**Steps:**
1. Reinstall app (fresh install)
2. Launch app
3. Tap "Skip" button on first page

**Expected Results:**
- [ ] Onboarding dismisses immediately
- [ ] Main app appears
- [ ] Never shows onboarding again

---

## 2. Quick Log - Logging Macros

### Test 2.1: Open Quick Log
**Steps:**
1. Navigate to Today tab
2. Tap the blue "+" floating button

**Expected Results:**
- [ ] Modal sheet slides up from bottom
- [ ] Sheet has drag handle at top
- [ ] Title says "Log Macros"
- [ ] Three input fields visible: Protein, Carbs, Fat
- [ ] Custom numeric keyboard visible
- [ ] "Done" button at bottom
- [ ] Optional notes field visible (with character count if Pro)

### Test 2.2: Log Simple Entry
**Steps:**
1. Open Quick Log
2. Tap Protein field
3. Type "40" using custom keyboard
4. Tap Carbs field
5. Type "30"
6. Tap Fat field
7. Type "10"
8. Tap "Done"

**Expected Results:**
- [ ] Sheet dismisses
- [ ] Today view updates immediately
- [ ] Protein ring shows progress
- [ ] Carbs ring shows progress
- [ ] Fat ring shows progress
- [ ] Calorie count updates (40×4 + 30×4 + 10×9 = 370 calories)
- [ ] Entry count shows "1 entry today"
- [ ] No loading spinners or delays

### Test 2.3: Log Multiple Entries
**Steps:**
1. Log entry: 40P / 30C / 10F
2. Tap "+" again
3. Log entry: 35P / 25C / 8F
4. Tap "+" again
5. Log entry: 30P / 20C / 7F

**Expected Results:**
- [ ] All entries added successfully
- [ ] Totals show: 105P / 75C / 25F
- [ ] Calories: 945 total
- [ ] Entry count shows "3 entries today"
- [ ] Rings update correctly with cumulative progress

### Test 2.4: Decimal Values
**Steps:**
1. Open Quick Log
2. Enter: 42.5P / 33.3C / 12.7F
3. Tap "Done"

**Expected Results:**
- [ ] Decimal values accepted
- [ ] Calculations accurate
- [ ] Display rounds to whole numbers in UI (43P / 33C / 13F)

### Test 2.5: Custom Keyboard Functionality
**Steps:**
1. Open Quick Log
2. Test each keyboard button: 0-9, ".", backspace
3. Type "123.45"
4. Tap backspace multiple times

**Expected Results:**
- [ ] All number buttons work (0-9)
- [ ] Decimal point works
- [ ] Only one decimal point allowed per number
- [ ] Backspace deletes one character at a time
- [ ] Can completely clear field with backspace

### Test 2.6: Field Validation
**Steps:**
1. Open Quick Log
2. Leave all fields empty
3. Tap "Done"

**Expected Results:**
- [ ] Error message or prevention (cannot submit all zeros)
- [ ] OR automatically dismisses without creating entry

**Steps:**
1. Open Quick Log
2. Enter negative number: "-10"
3. Tap "Done"

**Expected Results:**
- [ ] Negative values rejected OR converted to positive

### Test 2.7: Dismiss Without Saving
**Steps:**
1. Open Quick Log
2. Enter: 50P / 40C / 15F
3. Swipe down to dismiss (don't tap Done)

**Expected Results:**
- [ ] Sheet dismisses
- [ ] Entry NOT saved
- [ ] Today totals unchanged

---

## 3. Today View - Progress Tracking

### Test 3.1: Visual Progress Display
**Setup:** Log entries to reach 50%, 100%, and 150% of goals

**Steps:**
1. Set goals: 100P / 150C / 50F
2. Log: 50P / 75C / 25F (50% of goals)
3. Observe rings and bars
4. Log: 50P / 75C / 25F (100% of goals)
5. Observe rings and bars
6. Log: 50P / 75C / 25F (150% of goals)
7. Observe rings and bars

**Expected Results:**
- [ ] At 50%: Rings half-filled, bars half-filled
- [ ] At 100%: Rings complete circle, bars fully filled
- [ ] At 150%: Rings complete + overflow indication, bars show over 100%
- [ ] Percentages displayed correctly (e.g., "50%" or "100%" or "150%")
- [ ] Colors: Blue (Protein), Green (Carbs), Yellow (Fat)

### Test 3.2: Date Display
**Steps:**
1. Check date display at top of Today view

**Expected Results:**
- [ ] Shows "Today" on left
- [ ] Shows current date on right (e.g., "Oct 26, 2025")
- [ ] Date updates at midnight

### Test 3.3: Calorie Calculation
**Steps:**
1. Log: 40P / 30C / 10F
2. Check calorie display

**Expected Results:**
- [ ] Calories calculated correctly: (40×4) + (30×4) + (10×9) = 370 cal
- [ ] Displays as "370 / [goal] kcal"

### Test 3.4: Zero State
**Setup:** Fresh app with no entries

**Steps:**
1. View Today screen with no logged macros

**Expected Results:**
- [ ] Rings are empty (just outlines)
- [ ] Progress bars empty
- [ ] Shows "0 / [goal] kcal"
- [ ] Entry count shows "0 entries today"

---

## 4. Goals Management

### Test 4.1: View Default Goals
**Steps:**
1. Navigate to Settings tab
2. Scroll to "Daily Goals" section

**Expected Results:**
- [ ] Default goals visible (likely 180P / 250C / 70F)
- [ ] Goals display in read-only mode initially
- [ ] "Edit" button visible

### Test 4.2: Edit Goals
**Steps:**
1. In Settings > Daily Goals section
2. Tap "Edit" button
3. Change Protein to "200"
4. Change Carbs to "300"
5. Change Fat to "80"
6. Tap "Save"

**Expected Results:**
- [ ] Input fields become editable
- [ ] Can type in each field
- [ ] "Save" and "Cancel" buttons appear
- [ ] After Save: Success message appears
- [ ] Goals update immediately
- [ ] Edit mode exits
- [ ] Navigate to Today tab - rings recalculate with new goals

### Test 4.3: Cancel Goal Editing
**Steps:**
1. Tap "Edit"
2. Change goals to different values
3. Tap "Cancel"

**Expected Results:**
- [ ] Changes discarded
- [ ] Original goals remain
- [ ] Edit mode exits

### Test 4.4: Invalid Goal Values
**Steps:**
1. Tap "Edit"
2. Enter "0" for Protein
3. Tap "Save"

**Expected Results:**
- [ ] Error message OR prevents saving
- [ ] Goals remain unchanged

**Steps:**
1. Tap "Edit"
2. Enter "-50" for Carbs
3. Tap "Save"

**Expected Results:**
- [ ] Error message OR converts to positive OR prevents saving

### Test 4.5: Goals Persist Across Launches
**Steps:**
1. Set custom goals: 150P / 200C / 60F
2. Force quit app
3. Relaunch app
4. Check Settings

**Expected Results:**
- [ ] Custom goals still saved
- [ ] Today view uses custom goals

---

## 5. History View

### Test 5.1: Calendar Navigation
**Steps:**
1. Navigate to History tab
2. View current month calendar
3. Tap left chevron (previous month)
4. Tap right chevron (next month)

**Expected Results:**
- [ ] Calendar shows current month by default
- [ ] Month/year displayed (e.g., "October 2025")
- [ ] Left chevron shows previous month
- [ ] Right chevron shows next month
- [ ] Calendar grid displays correctly with weekday headers (S M T W T F S)

### Test 5.2: Day Indicators
**Setup:** Log macros on multiple days

**Steps:**
1. Log macros today
2. Navigate to History tab
3. Check today's date

**Expected Results:**
- [ ] Today's date highlighted with blue circle
- [ ] Green dot appears under today's date (indicates data)
- [ ] Days with no data have no green dot

### Test 5.3: Free Tier Limit (Last 7 Days)
**Setup:** Not Pro user

**Steps:**
1. Ensure not Pro (Settings should show "Upgrade to Pro")
2. Go to History tab
3. Look at dates older than 7 days

**Expected Results:**
- [ ] Dates within last 7 days are normal
- [ ] Dates older than 7 days are grayed out
- [ ] Lock icon on dates older than 7 days
- [ ] Tapping locked day shows Pro upgrade prompt

### Test 5.4: Weekly Stats
**Setup:** Log macros for last 7 days

**Steps:**
1. View History tab
2. Scroll to "Weekly Averages" section

**Expected Results:**
- [ ] Shows average Protein (blue)
- [ ] Shows average Carbs (green)
- [ ] Shows average Fat (yellow)
- [ ] Calculations accurate

### Test 5.5: Streak Counter
**Setup:** Log macros for consecutive days

**Steps:**
1. Log macros today
2. Check "Streak" section in History

**Expected Results:**
- [ ] Shows "X Day Streak"
- [ ] Flame icon visible
- [ ] Encouragement message ("Keep it going!")
- [ ] If no entries today: streak should be 0 or previous streak

---

## 6. Pro Features

### Test 6.1: View Pro Upgrade Screen
**Steps:**
1. Go to Settings
2. Tap "Upgrade to Pro" banner

**Expected Results:**
- [ ] ProUpgradeView sheet appears
- [ ] Shows feature list
- [ ] Shows price ($4.99 one-time)
- [ ] "Purchase" button visible
- [ ] "Restore Purchases" button visible
- [ ] Dismissable with swipe down or X button

### Test 6.2: Unlock Pro (Test Purchase)
**Note:** Use StoreKit Testing or sandbox account

**Steps:**
1. Tap "Upgrade to Pro"
2. Tap "Purchase" button
3. Complete test purchase flow

**Expected Results:**
- [ ] StoreKit sheet appears
- [ ] Purchase processes
- [ ] Success message appears
- [ ] Pro badge appears in Settings
- [ ] Locked features unlock immediately
- [ ] "Upgrade to Pro" banners disappear

### Test 6.3: Pro Feature - Unlimited History
**Setup:** Be Pro user

**Steps:**
1. Go to History tab
2. Navigate to months in the past
3. Tap on old dates

**Expected Results:**
- [ ] No lock icons on old dates
- [ ] Can view all historical data
- [ ] Green dots show on all days with data (regardless of age)

### Test 6.4: Pro Feature - Notes on Entries
**Setup:** Be Pro user

**Steps:**
1. Open Quick Log
2. Check for Notes field
3. Type "Breakfast - Eggs & toast"
4. Log entry: 30P / 25C / 10F
5. Done

**Expected Results:**
- [ ] Notes field visible
- [ ] Character count shown (e.g., "23/100")
- [ ] Note saves with entry
- [ ] Note visible in history (if implemented)

### Test 6.5: Pro Feature - Macro Presets
**Setup:** Be Pro user

**Steps:**
1. Open Quick Log
2. Enter: 40P / 30C / 12F
3. Add note: "Chicken & Rice"
4. Tap "Save as Preset"
5. Name: "Lunch Bowl"
6. Save preset

**Expected Results:**
- [ ] "Save as Preset" option visible
- [ ] Preset name prompt appears
- [ ] Preset saved successfully
- [ ] Can access preset from Quick Log
- [ ] Tapping preset auto-fills values

### Test 6.6: Pro Feature - Use Preset
**Setup:** Have saved preset from Test 6.5

**Steps:**
1. Open Quick Log
2. Tap "Presets" or preset icon
3. Select "Lunch Bowl" preset

**Expected Results:**
- [ ] Preset list appears
- [ ] Shows all saved presets
- [ ] Tapping preset fills in: 40P / 30C / 12F
- [ ] Note field shows "Chicken & Rice"
- [ ] Can edit values before saving

### Test 6.7: Pro Feature - Edit/Delete Preset
**Steps:**
1. Go to Settings (or wherever presets are managed)
2. Find "Lunch Bowl" preset
3. Edit name to "Meal Prep Bowl"
4. Save
5. Delete a preset

**Expected Results:**
- [ ] Can edit preset name and values
- [ ] Changes save successfully
- [ ] Delete confirmation prompt appears
- [ ] Preset deleted from list

### Test 6.8: Pro Feature - Themes
**Setup:** Be Pro user

**Steps:**
1. Go to Settings > Appearance > Theme
2. View available themes
3. Select "Mint" theme
4. Navigate through app

**Expected Results:**
- [ ] Theme picker shows all 6 themes:
  - Free: System, Dark, Dark Grey, Light
  - Pro: Mint, Sunset, Ocean
- [ ] Can select any theme (no locks)
- [ ] Theme applies app-wide immediately
- [ ] Ring colors change (Mint theme has different colors)
- [ ] Background changes if applicable

### Test 6.9: Pro Feature - Custom Daily Goals
**Setup:** Be Pro user

**Steps:**
1. Go to Settings > Daily Goals
2. Tap "Custom Daily Goals"
3. Set different goals for Monday: 200P / 250C / 70F
4. Set different goals for Wednesday: 150P / 200C / 50F
5. Save
6. Check Today view on Monday vs Wednesday

**Expected Results:**
- [ ] Custom Daily Goals screen appears
- [ ] Can set different goals per weekday
- [ ] Goals save successfully
- [ ] Today view uses correct goals based on day of week

### Test 6.10: Pro Feature - Export Data
**Setup:** Be Pro user with several logged entries

**Steps:**
1. Go to Settings > Data section
2. Tap "Export Data"
3. Wait for share sheet

**Expected Results:**
- [ ] CSV file generates
- [ ] iOS share sheet appears
- [ ] Can share via AirDrop, Mail, Files, etc.
- [ ] CSV contains all entries with columns: Date, Protein, Carbs, Fat, Calories, Notes

### Test 6.11: Pro Feature - Week & Month View Analytics
**Setup:** Be Pro user

**Steps:**
1. Go to History tab
2. Tap view mode picker in top-right
3. Select "Week"
4. Review week view
5. Select "Month"
6. Review month view

**Expected Results:**
- [ ] Picker shows: Day, Week, Month
- [ ] Week view: Shows last 7 days as bar chart
- [ ] Week view: Shows weekly averages
- [ ] Month view: Shows last 30 days
- [ ] Month view: Shows monthly averages

### Test 6.12: Restore Purchases
**Steps:**
1. Delete and reinstall app
2. Go to Settings
3. Tap "Upgrade to Pro"
4. Tap "Restore Purchases"

**Expected Results:**
- [ ] Restore button works
- [ ] Pro status restored
- [ ] All Pro features unlock
- [ ] No re-purchase required

---

## 7. iCloud Sync

### Test 7.1: Single Device Sync
**Setup:** iCloud signed in

**Steps:**
1. Log entry: 40P / 30C / 10F
2. Wait 5-10 seconds
3. Check console logs (Xcode) for sync messages

**Expected Results:**
- [ ] Console shows "📤 Uploading X entries to CloudKit"
- [ ] Console shows "✅ Successfully uploaded"
- [ ] No error messages

### Test 7.2: Multi-Device Sync
**Setup:** Two devices (real devices or simulators) with same iCloud account

**Steps on Device 1:**
1. Log entry: 50P / 40C / 15F
2. Wait 30 seconds

**Steps on Device 2:**
3. Launch app
4. Pull to refresh (if implemented) OR wait for auto-sync
5. Check Today view

**Expected Results:**
- [ ] Entry appears on Device 2
- [ ] Totals match Device 1
- [ ] Entry count matches

### Test 7.3: Goal Sync
**Steps on Device 1:**
1. Change goals to: 200P / 300C / 80F
2. Wait 30 seconds

**Steps on Device 2:**
3. Launch app
4. Check Settings > Daily Goals

**Expected Results:**
- [ ] Goals sync to Device 2
- [ ] Both devices show same goals

### Test 7.4: Offline Mode
**Steps:**
1. Enable Airplane Mode
2. Log entry: 30P / 25C / 8F
3. Disable Airplane Mode
4. Wait for sync

**Expected Results:**
- [ ] Entry logs successfully while offline
- [ ] Stored in local CoreData
- [ ] Syncs to CloudKit when back online
- [ ] No data loss

### Test 7.5: Sync Status Indicator
**Steps:**
1. Go to Settings
2. Find iCloud Sync status

**Expected Results:**
- [ ] Shows "Automatic" or similar status
- [ ] OR shows last sync time
- [ ] No errors displayed

---

## 8. Siri Shortcuts

### Test 8.1: Log Macros via Siri
**Steps:**
1. Say: "Hey Siri, log macros in MacroSnap"
2. Siri asks for protein
3. Say "40"
4. Siri asks for carbs
5. Say "30"
6. Siri asks for fat
7. Say "10"

**Expected Results:**
- [ ] Siri recognizes command
- [ ] Siri prompts for each macro in order
- [ ] Entry logs successfully
- [ ] Siri confirms: "Logged 40 grams protein, 30 grams carbs, 10 grams fat. That's 370 calories. Great job!"
- [ ] Entry appears in app

### Test 8.2: Show Macros via Siri
**Setup:** Have logged entries today

**Steps:**
1. Say: "Hey Siri, show my macros today in MacroSnap"

**Expected Results:**
- [ ] Siri opens app
- [ ] Siri reads back totals: "Today you've logged X protein, Y carbs, Z fat. That's XXX calories total."
- [ ] App opens to Today view

### Test 8.3: Siri with No Entries
**Setup:** Fresh day with no entries

**Steps:**
1. Say: "Hey Siri, show my macros today in MacroSnap"

**Expected Results:**
- [ ] Siri says: "You haven't logged any macros today yet. Time to get started!"
- [ ] App opens

---

## 9. Edge Cases & Error Handling

### Test 9.1: Large Numbers
**Steps:**
1. Open Quick Log
2. Enter: 9999P / 9999C / 9999F
3. Tap Done

**Expected Results:**
- [ ] Entry logs without crashing
- [ ] OR validation prevents absurdly large numbers
- [ ] Calculations accurate

### Test 9.2: Very Small Numbers
**Steps:**
1. Log: 0.1P / 0.1C / 0.1F
2. Check display

**Expected Results:**
- [ ] Accepts small decimals
- [ ] OR rounds to reasonable precision

### Test 9.3: Rapid Logging
**Steps:**
1. Quickly log 10 entries in rapid succession
2. Check Today totals

**Expected Results:**
- [ ] All entries save
- [ ] No entries lost
- [ ] Totals calculate correctly
- [ ] No UI glitches or crashes

### Test 9.4: Background/Foreground
**Steps:**
1. Log entry: 40P / 30C / 10F
2. Swipe up to home screen (background app)
3. Wait 5 minutes
4. Reopen app

**Expected Results:**
- [ ] Entry still present
- [ ] Totals correct
- [ ] No data loss

### Test 9.5: Low Storage
**Note:** May need to simulate

**Steps:**
1. Fill device storage to nearly full
2. Attempt to log entry

**Expected Results:**
- [ ] Entry logs OR error message appears
- [ ] App doesn't crash

### Test 9.6: iCloud Storage Full
**Note:** Hard to test without actual full iCloud

**Expected Results:**
- [ ] App continues to work locally
- [ ] Shows sync warning/error
- [ ] Doesn't crash

### Test 9.7: App Force Quit During Entry
**Steps:**
1. Open Quick Log
2. Enter: 50P / 40C / 15F
3. Force quit app (swipe up in app switcher)
4. Relaunch app

**Expected Results:**
- [ ] Entry NOT saved (expected behavior)
- [ ] App launches normally
- [ ] No corrupted data

### Test 9.8: Change Device Date/Time
**Steps:**
1. Change device date to yesterday
2. Log entry
3. Change device date back to today
4. Check History

**Expected Results:**
- [ ] Entry appears on yesterday's date in History
- [ ] Calendar shows correct date
- [ ] No duplicate entries or confusion

---

## 10. Visual & UI Polish

### Test 10.1: Dark Grey Theme Consistency
**Steps:**
1. Navigate through all tabs: Today, History, Settings
2. Check background color

**Expected Results:**
- [ ] All screens use Dark Grey background (#212123)
- [ ] Not pure black
- [ ] Consistent across all views
- [ ] Onboarding also uses Dark Grey

### Test 10.2: Animations
**Steps:**
1. Log entry and watch rings animate
2. Navigate between tabs
3. Open/close Quick Log sheet

**Expected Results:**
- [ ] Ring filling animations smooth
- [ ] Progress bar animations smooth
- [ ] Tab switching smooth
- [ ] Sheet animations smooth (slide up/down)
- [ ] No janky or laggy animations

### Test 10.3: Typography & Spacing
**Steps:**
1. Review all screens for readability
2. Check text sizes and spacing

**Expected Results:**
- [ ] Text readable at all sizes
- [ ] Proper spacing between elements
- [ ] No overlapping text
- [ ] Consistent font weights

### Test 10.4: Safe Area Handling
**Steps:**
1. Test on notched devices (iPhone 16)
2. Test on older devices (iPhone SE)

**Expected Results:**
- [ ] Content doesn't hide behind notch
- [ ] Tab bar accessible
- [ ] No content cut off

---

## 11. Performance

### Test 11.1: App Launch Time
**Steps:**
1. Force quit app
2. Time app launch

**Expected Results:**
- [ ] Launches in < 2 seconds
- [ ] Shows content immediately (no blank screens)

### Test 11.2: Quick Log Open Time
**Steps:**
1. Tap "+" button
2. Time sheet appearance

**Expected Results:**
- [ ] Sheet appears instantly (< 0.5s)
- [ ] No lag or stutter

### Test 11.3: 100+ Entries Performance
**Setup:** Create 100+ macro entries

**Steps:**
1. Navigate to History
2. Scroll through calendar
3. Check weekly stats

**Expected Results:**
- [ ] No lag when scrolling
- [ ] Calculations fast
- [ ] Stats update quickly

---

## Test Results Summary

### Critical Issues (Must Fix Before Launch)
- [ ] List any critical bugs found:

### Medium Priority Issues
- [ ] List medium priority issues:

### Low Priority / Nice-to-Have
- [ ] List minor issues or enhancements:

### Overall Quality Assessment
- [ ] All critical features work: YES / NO
- [ ] Ready for TestFlight: YES / NO
- [ ] Ready for App Store: YES / NO

---

## Sign-Off

**Tester Name:** _______________
**Test Date:** _______________
**Build Version:** _______________
**Device(s) Tested:** _______________

**Notes:**

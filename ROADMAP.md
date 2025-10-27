# MacroSnap Development Roadmap

This roadmap outlines the development phases for MacroSnap, from MVP to advanced features. The goal is to launch a polished, focused product quickly, then iterate based on user feedback.

---

## **Phase 1: MVP (Weeks 1-4) 🎯**

### **Goal**: Launch-ready core functionality

#### Data Layer (Foundation)
- [x] CloudKit schema setup
  - Macro entries (date, protein, carbs, fat, notes, timestamp)
  - Goals (protein_goal, carb_goal, fat_goal)
  - Presets (name, protein, carbs, fat)
- [x] Local CoreData for offline-first storage
- [x] CoreData + CloudKit sync integration

#### Navigation
- [x] Tab bar (Today, History, Settings)
- [x] Tab switching logic
- [x] State management

#### Core Tracking (Screen 1: Today)
- [x] Date display (Today + current date)
- [x] Visual progress rings (Protein, Carbs, Fat)
- [x] Progress bars with gram counts
- [x] Daily macro totals and percentages
- [x] Floating "+" button

#### Quick Log (Screen 2: Modal Sheet)
- [x] Modal sheet with drag handle
- [x] Three macro input fields (P/C/F)
- [x] Field focus management
- [x] Custom numeric keypad (0-9, ., backspace)
- [x] Input validation (positive numbers only)
- [x] "Done" button to save entry
- [x] Add entry to today's total

#### Data Sync
- [x] Sync logic (CoreData ↔ CloudKit)
- [x] iCloud automatic sync
- [x] Conflict resolution (last-write-wins)

#### Settings (Screen 4: Basic)
- [x] Daily goals editor (3 number inputs)
- [x] Save goals to CoreData
- [x] iCloud sync status
- [x] Privacy Policy link
- [x] Contact Support link

**Deliverable**: ✅ Functional app with core tracking, iCloud sync, and basic settings

---

## **Phase 2: History & Stats (Weeks 5-6) 📊**

### **Goal**: Add 7-day history and basic analytics

#### History Screen - Calendar UI
- [x] Calendar view (current month)
- [x] Show today's date indicator
- [x] Monthly navigation (< October 2025 >)

#### History Screen - Data Display
- [x] Highlight last 7 days with data

#### Basic Stats
- [x] Weekly average calculation (P/C/F)
- [x] Streak counter (consecutive tracking days)
- [x] Display stats below calendar

#### Free Tier Limits
- [x] Gray out days beyond 7-day limit (free tier)
- [x] Lock icon on days beyond 7-day limit

#### Pro Upsell
- [x] Banner: "Unlock Unlimited History with Pro"
- [x] Tap locked days → Pro upgrade prompt

**Deliverable**: ✅ Users can review their last 7 days and see basic progress stats

---

## **Phase 3: Widgets (Weeks 7-8) 📱**

### **Goal**: iOS home screen and lock screen integration

#### Widget Infrastructure (Foundation)
- [ ] WidgetKit implementation
- [ ] Shared data container (App Groups)
- [ ] Widget timeline provider
- [ ] Background refresh

#### Home Screen Widgets (FREE)
- [ ] Small widget (rings only)
- [ ] Medium widget (rings + gram counts)
- [ ] Widget configuration
- [ ] Widget tap → Open app to Today screen
- [ ] Live data updates

#### Lock Screen Widgets (PRO)
- [ ] Circular widget (3 mini rings)
- [ ] Lock screen integration
- [ ] Real-time updates

**Deliverable**: Users can add MacroSnap widgets to home screen and lock screen

---

## **Phase 4: Pro Features (Weeks 9-10) 💎**

### **Goal**: Implement paid features and in-app purchase

#### In-App Purchase Setup (Foundation)
- [x] StoreKit 2 integration
- [x] One-time purchase: $4.99
- [x] Receipt validation (local)
- [x] Pro status sync via CloudKit
- [x] Restore purchases

#### Pro UI & Purchase Flow
- [x] Purchase flow UI
- [x] Pro badge in Settings
- [x] "Unlock Pro" banners throughout app
- [x] Pro feature lock icons (🔒)
- [x] Settings: Show Pro features as unlocked

#### Pro Feature: Unlimited History
- [x] Remove 7-day limit for Pro users
- [x] Allow calendar scrolling to previous months
- [x] Tap any historical day → Show full stats

#### Pro Feature: Notes & Meal Names
- [x] Add notes field to Quick Log sheet
- [x] Character limit (e.g., 100 chars)
- [x] Display notes in history

#### Pro Feature: Macro Presets
- [x] "Save as Preset" button in Quick Log
- [x] Preset library screen
- [x] Tap preset → Auto-fill macros
- [x] Edit/delete presets
- [x] Store presets in CoreData + CloudKit sync

#### Pro Feature: Themes
- [x] 6 theme options (System, Dark, Dark Grey, Light, Mint, Sunset, Ocean)
- [x] Free themes: System, Dark, Dark Grey, Light
- [x] Pro themes: Mint, Sunset, Ocean
- [x] Dark Grey set as default theme (subtle charcoal #212123)
- [x] Theme picker in Settings
- [x] Apply theme app-wide (all screens + onboarding)
- [x] Store preference in UserDefaults + CloudKit sync

#### Pro Feature: Custom Daily Goals
- [x] Advanced goals screen
- [x] Set different goals per day of week
- [x] Store in CoreData with CloudKit sync
- [x] Update AppState to use day-specific goals

#### Pro Feature: Week & Month View Analytics
- [x] Toggle in History screen title
- [x] Week view: 7-day bar chart
- [x] Month view: 30-day chart
- [x] Show averages and trends

#### Pro Feature: Export Data
- [x] Generate CSV from user's macro history
- [x] Include columns: Date, Protein, Carbs, Fat, Calories, Notes
- [x] Share sheet to save/email CSV

**Deliverable**: Complete Pro tier with all premium features and payment flow

---

## **Phase 5: Polish & Testing (Weeks 11-12) ✨**

### **Goal**: Bug fixes, performance, and App Store readiness

#### Polish - UI/UX
- [ ] Loading states and animations
- [ ] Empty states (no data yet)
- [ ] Haptic feedback
- [x] Dark mode refinements (Dark Grey theme added as default)

#### Polish - Robustness
- [ ] Error handling (network, validation)
- [ ] Accessibility (VoiceOver, Dynamic Type)

#### Polish - Performance
- [ ] Performance optimization
  - Reduce database queries
  - Optimize widget updates
  - Memory management

#### Testing - Automated
- [ ] Unit tests (data layer, calculations)
- [ ] UI tests (critical flows)

#### Testing - Beta
- [ ] TestFlight beta
  - Recruit 20-50 testers
  - Fix critical bugs
  - Gather feedback

#### Legal & Compliance
- [ ] Privacy policy finalized
- [ ] Privacy policy page
- [ ] Terms of service
- [ ] App Store Review Guidelines compliance
- [ ] GDPR compliance (if applicable)

#### App Store Prep
- [ ] App icon (1024x1024)
- [ ] Screenshots (6.7", 6.5", 5.5" displays)
- [ ] App Store description
- [ ] Support email setup
- [ ] App Store metadata
- [ ] Promo video (optional but recommended)

**Deliverable**: App Store submission-ready build

---

## **Phase 6: Launch (Week 13) 🚀**

### Pre-Launch
- [ ] Final TestFlight build
- [ ] App Store submission
- [ ] Review (typically 1-3 days)

### Launch Day
- [ ] App goes live on App Store
- [ ] Product Hunt launch
- [ ] Reddit posts (r/fitness, r/bodybuilding, r/MacrosFirst)
- [ ] Twitter/X announcement with demo video
- [ ] Email to TestFlight testers

### Post-Launch Monitoring
- [ ] Monitor crash reports
- [ ] Respond to user reviews
- [ ] Track downloads and revenue
- [ ] Gather user feedback
- [ ] Hot fixes if needed

**Deliverable**: MacroSnap live on App Store

---

## **Phase 7: Post-Launch Iterations (Months 2-3) 🔄**

### **Goal**: Improve based on user feedback and add high-demand features

#### Analytics & Monitoring (Foundation)
- [ ] Add basic analytics (privacy-friendly)
  - DAU/MAU tracking
  - Feature usage
  - Conversion rates (free → Pro)
- [ ] Crash reporting (e.g., Sentry)
- [ ] Performance monitoring

#### Quick Improvements
- [x] Onboarding tutorial (first launch)
- [ ] Better empty states
- [ ] Improved Pro upgrade flow

#### User-Requested Features (Prioritize Based on Feedback)
- [ ] Meal timing (log time with each entry)
- [ ] Undo last entry
- [ ] Quick add from Today screen (skip modal)
- [ ] Weekly goal setting (different goals per week)
- [ ] Multiple daily goal templates
- [ ] Photo attachments for meals
- [ ] Water tracking (if highly requested)

#### Platform Expansion
- [ ] More widget sizes/styles
- [ ] iPad optimization (if user base warrants it)

**Deliverable**: v1.1 or v1.2 with improvements and new features

---

## **Phase 8: Advanced Features (Months 4-6+) 🎨**

### **Goal**: Differentiate from competitors with unique features

#### Siri Shortcuts & App Intents
- [x] "Log 40 protein, 30 carbs, 10 fat" voice command
- [x] "Show my macros today"
- [x] Custom shortcuts in Shortcuts app

#### Dynamic Island (iPhone 14 Pro+)
- [ ] Show live macro progress during meals
- [ ] Tap to open Quick Log
- [ ] Live Activities integration

#### Advanced Analytics (Pro)
- [ ] Macro trends over time
- [ ] Goal achievement rate
- [ ] Weekly/monthly reports
- [ ] Compare weeks/months

#### Apple Watch App (if user base warrants)
- [ ] View today's progress on watch
- [ ] Quick log via watch
- [ ] Complications for watch faces

#### Smart Features (AI-Powered)
- [ ] Meal photo → AI estimates macros (via OpenAI Vision API)
- [ ] Voice input: "I had 40 grams of protein"
- [ ] Smart suggestions based on time of day
- [ ] Macro balance recommendations

#### Social Features (OPTIONAL - contradicts "no social" philosophy)
- [ ] Share progress image to social media
- [ ] Accountability partner (private, 1-on-1 only)
- **Note**: Only add if users explicitly request and it doesn't bloat the app

**Deliverable**: Advanced features that maintain simplicity while adding unique value

---

## **Success Metrics**

### Year 1 Goals
- **Downloads**: 25,000
- **Active Users (MAU)**: 10,000
- **Pro Conversion**: 15% (3,750 purchases)
- **Revenue**: ~$13,125 (after Apple's cut)
- **Rating**: 4.5+ stars
- **Featured**: "New Apps We Love" or "App of the Day"

### Key Performance Indicators (KPIs)
- **Daily Active Users (DAU)**
- **Retention**: D1 (Day 1), D7, D30
- **Pro conversion rate**
- **Average session length**
- **Crash-free rate (target: >99.5%)**
- **App Store rating**

---

## **Technology Roadmap**

### Current Stack (Phase 1-6)
- SwiftUI
- CloudKit (iCloud sync)
- CoreData (Local storage, offline-first)
- WidgetKit
- StoreKit 2

### Future Considerations
- **Push Notifications**: Daily reminders (opt-in)
- **Background Sync**: More aggressive CloudKit sync strategy
- **Advanced Conflict Resolution**: Smart merge strategies for simultaneous edits

---

## **Maintenance & Support**

### Ongoing (Post-Launch)
- **Weekly**: Monitor reviews, respond to critical issues
- **Monthly**: Review analytics, plan next iteration
- **Quarterly**: iOS updates, bug fixes, minor improvements
- **As Needed**: Hot fixes for critical bugs

### Estimated Time Commitment
- **Months 1-3**: 10-15 hrs/week (high engagement)
- **Months 4-6**: 5-10 hrs/week
- **Months 7+**: <5 hrs/week (sustainable maintenance)

---

## **Risk Mitigation**

### Technical Risks
- **iCloud quota**: Users on free plan limited to 5GB (educate about data size)
- **Apple rejection**: Follow guidelines strictly, ensure proper CloudKit setup
- **Performance issues**: Profile early, optimize widgets and sync

### Business Risks
- **Low downloads**: Invest in marketing, Reddit/Twitter presence
- **Low Pro conversion**: A/B test pricing, add more Pro value
- **Competitor copies**: Move fast, maintain quality, build loyal user base

---

## **Principles**

Throughout all phases, maintain these core principles:

1. **Speed First**: Every feature must be fast. No loading spinners if avoidable.
2. **No Bloat**: Say no to features that don't serve the core use case.
3. **Native Feel**: iOS conventions over custom designs.
4. **Privacy Always**: No tracking, no data selling, minimal analytics.
5. **One Thing Well**: Macro tracking. Not exercise. Not recipes. Just macros.

---

**Last Updated**: 2025-10-26
**Target Launch**: Q1 2026 (13 weeks from start)

//
//  HistoryView.swift
//  MacroSnap
//
//  History screen - Calendar and past entries (Screen 3)
//

import SwiftUI
import CoreData

enum HistoryViewMode {
    case day
    case week
    case month
}

// Make Date identifiable for sheet presentation
extension Date: Identifiable {
    public var id: TimeInterval {
        self.timeIntervalSince1970
    }
}

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var storeManager = StoreManager.shared

    @State private var currentMonth: Date = Date()
    @State private var daysWithData: Set<Date> = []
    @State private var showProUpgradePrompt = false
    @State private var showProUpgradeView = false
    @State private var viewMode: HistoryViewMode = .day
    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        NavigationView {
            ZStack {
                // Apply custom background color if theme has one
                if let bgColor = appState.themeManager.currentTheme.backgroundColor {
                    bgColor.ignoresSafeArea()
                }

                ScrollView {
                    VStack(spacing: 24) {
                    // Show different content based on view mode
                    switch viewMode {
                    case .day:
                        // MARK: - Month Header with Navigation
                        monthNavigationHeader

                        // MARK: - Calendar Grid
                        calendarGrid

                        // MARK: - Stats Section
                        statsSection

                    case .week:
                        // MARK: - Week View
                        weekView

                    case .month:
                        // MARK: - Month View
                        monthView
                    }

                    // MARK: - Pro Upgrade Banner (only show if not Pro)
                    if !storeManager.isPro {
                        proUpgradeBanner
                    }

                    Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if storeManager.isPro {
                        viewModePicker
                    }
                }
            }
            .sheet(isPresented: $showProUpgradeView) {
                ProUpgradeView()
            }
            .sheet(item: $selectedDate) { date in
                DayEntriesSheet(date: date)
                    .environmentObject(appState)
                    .environment(\.managedObjectContext, viewContext)
            }
            .alert("Unlock Unlimited History", isPresented: $showProUpgradePrompt) {
                Button("Upgrade to Pro") {
                    showProUpgradeView = true
                }
                Button("Not Now", role: .cancel) { }
            } message: {
                Text("Get access to your complete macro history with MacroSnap Pro!")
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - View Mode Picker

    private var viewModePicker: some View {
        Picker("View Mode", selection: $viewMode) {
            Text("Day").tag(HistoryViewMode.day)
            Text("Week").tag(HistoryViewMode.week)
            Text("Month").tag(HistoryViewMode.month)
        }
        .pickerStyle(.segmented)
        .frame(width: 200)
    }

    // MARK: - Week View

    private var weekView: some View {
        VStack(spacing: 24) {
            Text("Last 7 Days")
                .font(.title2)
                .fontWeight(.bold)

            // Bar chart
            VStack(spacing: 16) {
                ForEach(last7Days.reversed(), id: \.self) { date in
                    WeekDayRow(date: date, entries: entriesForDate(date))
                }
            }

            // Weekly totals
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    StatCard(title: "Avg Protein", value: weeklyAverageProtein, color: .blue)
                    StatCard(title: "Avg Carbs", value: weeklyAverageCarbs, color: .green)
                    StatCard(title: "Avg Fat", value: weeklyAverageFat, color: .yellow)
                }
            }
        }
    }

    // MARK: - Month View

    private var monthView: some View {
        VStack(spacing: 24) {
            Text("Last 30 Days")
                .font(.title2)
                .fontWeight(.bold)

            // Monthly trend chart (simplified as bars)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(last30Days.reversed(), id: \.self) { date in
                        MonthDayBar(date: date, entries: entriesForDate(date))
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 200)

            // Monthly averages
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    StatCard(title: "Avg Protein", value: monthlyAverageProtein, color: .blue)
                    StatCard(title: "Avg Carbs", value: monthlyAverageCarbs, color: .green)
                    StatCard(title: "Avg Fat", value: monthlyAverageFat, color: .yellow)
                }
            }
        }
    }

    // MARK: - Pro Upgrade Banner

    private var proUpgradeBanner: some View {
        Button(action: {
            showProUpgradeView = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Unlock Unlimited History")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Access your complete tracking history")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 16) {
            // Weekly Averages
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Averages")
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 20) {
                    StatCard(title: "Protein", value: weeklyAverageProtein, color: .blue)
                    StatCard(title: "Carbs", value: weeklyAverageCarbs, color: .green)
                    StatCard(title: "Fat", value: weeklyAverageFat, color: .yellow)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )

            // Streak Counter
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(currentStreak) Day Streak")
                        .font(.headline)
                    Text("Keep it going!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
            )
        }
    }

    // MARK: - Month Navigation Header

    private var monthNavigationHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.blue)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: 12) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isToday: calendar.isDateInToday(date),
                            hasData: hasDataForDate(date),
                            isInLast7Days: isDateInLast7Days(date),
                            isPro: storeManager.isPro,
                            onDayTapped: {
                                if hasDataForDate(date) && (isDateInLast7Days(date) || storeManager.isPro || calendar.isDateInToday(date)) {
                                    print("🖱️ Day tapped: \(date)")
                                    selectedDate = date
                                }
                            },
                            onLockedDayTapped: {
                                showProUpgradePrompt = true
                            }
                        )
                    } else {
                        // Empty cell for padding
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
        }
        .onAppear(perform: loadDaysWithData)
        .onChange(of: currentMonth) { _ in
            loadDaysWithData()
        }
    }

    // MARK: - Computed Properties

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }

        let firstDayOfMonth = monthInterval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0

        // Calculate padding for the first week
        let paddingDays = firstWeekday - 1

        var days: [Date?] = Array(repeating: nil, count: paddingDays)

        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    // MARK: - Actions

    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    // MARK: - Data Loading

    private func loadDaysWithData() {
        // Fetch all entries from CoreData
        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()

        do {
            let entries = try viewContext.fetch(fetchRequest)

            // Create a set of dates with data (normalized to start of day)
            daysWithData = Set(entries.compactMap { entry in
                guard let date = entry.date else { return nil }
                return calendar.startOfDay(for: date)
            })
        } catch {
            print("Failed to fetch entries: \(error)")
        }
    }

    private func hasDataForDate(_ date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        return daysWithData.contains(normalizedDate)
    }

    private func isDateInLast7Days(_ date: Date) -> Bool {
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: Date()) else {
            return false
        }
        let sevenDaysAgoNormalized = calendar.startOfDay(for: sevenDaysAgo)
        let dateNormalized = calendar.startOfDay(for: date)
        let todayNormalized = calendar.startOfDay(for: Date())

        return dateNormalized >= sevenDaysAgoNormalized && dateNormalized <= todayNormalized
    }

    // MARK: - Helper Computed Properties

    private var last7Days: [Date] {
        var days: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                days.append(calendar.startOfDay(for: date))
            }
        }
        return days
    }

    private var last30Days: [Date] {
        var days: [Date] = []
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                days.append(calendar.startOfDay(for: date))
            }
        }
        return days
    }

    private func entriesForDate(_ date: Date) -> [MacroEntryEntity] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                             startOfDay as NSDate,
                                             endOfDay as NSDate)

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch entries for date: \(error)")
            return []
        }
    }

    // MARK: - Stats Calculations

    private var weeklyAverageProtein: Double {
        return calculateWeeklyAverage(for: \.protein)
    }

    private var weeklyAverageCarbs: Double {
        return calculateWeeklyAverage(for: \.carbs)
    }

    private var weeklyAverageFat: Double {
        return calculateWeeklyAverage(for: \.fat)
    }

    private func calculateWeeklyAverage(for keyPath: KeyPath<MacroEntryEntity, Double>) -> Double {
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: Date()) else {
            return 0
        }

        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@",
                                             sevenDaysAgo as NSDate,
                                             Date() as NSDate)

        do {
            let entries = try viewContext.fetch(fetchRequest)
            guard !entries.isEmpty else { return 0 }

            let total = entries.reduce(0.0) { $0 + $1[keyPath: keyPath] }
            return total / Double(entries.count)
        } catch {
            print("Failed to calculate weekly average: \(error)")
            return 0
        }
    }

    private var monthlyAverageProtein: Double {
        return calculateMonthlyAverage(for: \.protein)
    }

    private var monthlyAverageCarbs: Double {
        return calculateMonthlyAverage(for: \.carbs)
    }

    private var monthlyAverageFat: Double {
        return calculateMonthlyAverage(for: \.fat)
    }

    private func calculateMonthlyAverage(for keyPath: KeyPath<MacroEntryEntity, Double>) -> Double {
        guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -29, to: Date()) else {
            return 0
        }

        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@",
                                             thirtyDaysAgo as NSDate,
                                             Date() as NSDate)

        do {
            let entries = try viewContext.fetch(fetchRequest)
            guard !entries.isEmpty else { return 0 }

            let total = entries.reduce(0.0) { $0 + $1[keyPath: keyPath] }
            return total / Double(entries.count)
        } catch {
            print("Failed to calculate monthly average: \(error)")
            return 0
        }
    }

    private var currentStreak: Int {
        // Fetch all entries sorted by date descending
        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let entries = try viewContext.fetch(fetchRequest)
            guard !entries.isEmpty else { return 0 }

            // Group entries by day
            var daysWithEntries = Set<Date>()
            for entry in entries {
                if let date = entry.date {
                    daysWithEntries.insert(calendar.startOfDay(for: date))
                }
            }

            // Calculate streak - start from yesterday if no entries today (give benefit of the doubt)
            let today = calendar.startOfDay(for: Date())
            let hasLoggedToday = daysWithEntries.contains(today)

            // Start counting from today if logged, otherwise from yesterday
            var currentDate = hasLoggedToday ? today : calendar.date(byAdding: .day, value: -1, to: today)!
            var streak = 0

            while daysWithEntries.contains(currentDate) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            }

            return streak
        } catch {
            print("Failed to calculate streak: \(error)")
            return 0
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let isToday: Bool
    let hasData: Bool
    let isInLast7Days: Bool
    let isPro: Bool
    let onDayTapped: () -> Void
    let onLockedDayTapped: () -> Void

    private let calendar = Calendar.current
    private var isLocked: Bool {
        // Lock days beyond 7-day limit only for non-Pro users
        !isPro && !isInLast7Days && !Calendar.current.isDateInToday(date) && date < Date()
    }

    var body: some View {
        Button(action: {
            if isLocked {
                onLockedDayTapped()
            } else if hasData {
                onDayTapped()
            }
        }) {
            ZStack {
                VStack(spacing: 0) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 16, weight: isToday ? .bold : .regular))
                        .foregroundColor(foregroundColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Circle()
                                .fill(isToday ? Color.blue : Color.clear)
                        )
                        .overlay(
                            Circle()
                                .stroke(isToday ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .opacity(isLocked ? 0.3 : 1.0)

                    // Data indicator dot - show for last 7 days (free) or all days (Pro)
                    if hasData && (isInLast7Days || isPro) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 4, height: 4)
                            .padding(.top, 2)
                    } else {
                        // Placeholder to maintain spacing
                        Color.clear
                            .frame(width: 4, height: 4)
                            .padding(.top, 2)
                    }
                }

                // Lock icon for days beyond 7-day limit
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isLocked && !hasData)
    }

    private var foregroundColor: Color {
        if isLocked {
            return .gray
        } else if isToday {
            return .white
        } else {
            return .primary
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(Int(value))g")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Week Day Row Component

struct WeekDayRow: View {
    let date: Date
    let entries: [MacroEntryEntity]

    private let calendar = Calendar.current

    private var dayLabel: String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: date)
        }
    }

    private var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }

    private var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbs }
    }

    private var totalFat: Double {
        entries.reduce(0) { $0 + $1.fat }
    }

    private var totalCalories: Double {
        (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dayLabel)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 4) {
                // Protein bar
                MacroBar(value: totalProtein, color: .blue, maxValue: 300)

                // Carbs bar
                MacroBar(value: totalCarbs, color: .green, maxValue: 400)

                // Fat bar
                MacroBar(value: totalFat, color: .yellow, maxValue: 150)
            }
            .frame(height: 30)

            HStack(spacing: 12) {
                MacroLabel(label: "P", value: Int(totalProtein), color: .blue)
                MacroLabel(label: "C", value: Int(totalCarbs), color: .green)
                MacroLabel(label: "F", value: Int(totalFat), color: .yellow)

                Spacer()

                Text("\(Int(totalCalories)) cal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Month Day Bar Component

struct MonthDayBar: View {
    let date: Date
    let entries: [MacroEntryEntity]

    private let calendar = Calendar.current

    private var totalCalories: Double {
        let protein = entries.reduce(0) { $0 + $1.protein }
        let carbs = entries.reduce(0) { $0 + $1.carbs }
        let fat = entries.reduce(0) { $0 + $1.fat }
        return (protein * 4) + (carbs * 4) + (fat * 9)
    }

    private var barHeight: CGFloat {
        let maxCalories: Double = 3000
        let height = (totalCalories / maxCalories) * 150
        return CGFloat(max(height, 2))
    }

    var body: some View {
        VStack(spacing: 4) {
            Spacer()

            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 8, height: barHeight)

            Text("\(calendar.component(.day, from: date))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(height: 180)
    }
}

// MARK: - Helper Components

struct MacroBar: View {
    let value: Double
    let color: Color
    let maxValue: Double

    private var barWidth: CGFloat {
        let percentage = min(value / maxValue, 1.0)
        return CGFloat(percentage * 80)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.2))

            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: barWidth)
        }
    }
}

struct MacroLabel: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text("\(value)g")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(AppState())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

//
//  LedgerView.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct LedgerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    
    @Query(sort: \DrinkLog.timestamp, order: .reverse)
    private var allLogs: [DrinkLog]
    
    @Query private var goals: [UserGoals]
    
    @State private var selectedPeriod: TimePeriod = .weekly
    @State private var selectedDate: Date = Date()
    
    private var filteredLogs: [DrinkLog] {
        switch selectedPeriod {
        case .weekly:
            return allLogs.forWeek(containing: selectedDate)
        case .monthly:
            return allLogs.forMonth(containing: selectedDate)
        }
    }
    
    private var periodSummary: MonthlySummary {
        let totalCups = filteredLogs.count
        let totalCalories = filteredLogs.reduce(0) { $0 + $1.calories }
        let totalSugar = filteredLogs.reduce(0) { $0 + $1.sugarGrams }
        let totalSpend = filteredLogs.reduce(0) { $0 + ($1.price ?? 0) }
        let longestStreak = filteredLogs.longestTeaFreeStreak(for: selectedPeriod, referenceDate: selectedDate)
        
        return MonthlySummary(
            totalCups: totalCups,
            totalCalories: totalCalories,
            totalSugar: totalSugar,
            totalSpend: totalSpend,
            longestTeaFreeStreak: longestStreak
        )
    }
    
    private var userGoals: UserGoals {
        if let existing = goals.first {
            return existing
        }
        
        // Create default goals if none exist
        let newGoals = UserGoals()
        modelContext.insert(newGoals)
        try? modelContext.save()
        return newGoals
    }
    
    private var currentCupGoal: Int? {
        selectedPeriod == .weekly ? userGoals.weeklyCupGoal : userGoals.monthlyCupGoal
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        
        switch selectedPeriod {
        case .weekly:
            formatter.dateFormat = "MMM d"
            let start = selectedDate.startOfWeek()
            let end = selectedDate.endOfWeek()
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = ", yyyy"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))\(yearFormatter.string(from: end))"
        case .monthly:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
        }
    }
    
    private var canGoNext: Bool {
        // Can't go to future periods
        let today = Date()
        switch selectedPeriod {
        case .weekly:
            return !selectedDate.isInSameWeek(as: today)
        case .monthly:
            return !selectedDate.isInSameMonth(as: today)
        }
    }
    
    private func goToPrevious() {
        withAnimation {
            switch selectedPeriod {
            case .weekly:
                selectedDate = selectedDate.previousWeek()
            case .monthly:
                selectedDate = selectedDate.previousMonth()
            }
        }
    }
    
    private func goToNext() {
        withAnimation {
            switch selectedPeriod {
            case .weekly:
                selectedDate = selectedDate.nextWeek()
            case .monthly:
                selectedDate = selectedDate.nextMonth()
            }
        }
    }
    
    private func resetToToday() {
        withAnimation {
            selectedDate = Date()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        Text(String(localized: "by_week")).tag(TimePeriod.weekly)
                        Text(String(localized: "by_month")).tag(TimePeriod.monthly)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedPeriod) { _, _ in
                        // Reset to current date when changing period type
                        selectedDate = Date()
                    }
                    
                    // Date Navigation Bar
                    HStack {
                        Button(action: goToPrevious) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                        }
                        
                        Spacer()
                        
                        Button(action: resetToToday) {
                            Text(dateRangeText)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: goToNext) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(canGoNext ? Color(red: 0.93, green: 0.26, blue: 0.55) : .gray)
                        }
                        .disabled(!canGoNext)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    
                    MonthlySummaryCard(summary: periodSummary, period: selectedPeriod, cupGoal: currentCupGoal)
                        .padding(.horizontal)
                    
                    MonthlyGoalsSection(
                        summary: periodSummary,
                        goals: userGoals,
                        period: selectedPeriod
                    )
                    .padding(.horizontal)
                    
                    DailyLogSection(logs: filteredLogs)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle(String(localized: "ledger"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    LedgerView()
        .environment(LanguageManager.shared)
        .modelContainer(for: [Brand.self, DrinkTemplate.self, DrinkLog.self, UserGoals.self])
}

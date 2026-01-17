//
//  LedgerView.swift
//  mikeTeaTracker
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
    
    @State private var selectedPeriod: TimePeriod = .monthly
    
    private var filteredLogs: [DrinkLog] {
        switch selectedPeriod {
        case .weekly:
            return allLogs.currentWeek()
        case .monthly:
            return allLogs.currentMonth()
        }
    }
    
    private var periodSummary: MonthlySummary {
        let totalCups = filteredLogs.count
        let totalCalories = filteredLogs.reduce(0) { $0 + $1.calories }
        let totalSugar = filteredLogs.reduce(0) { $0 + $1.sugarGrams }
        let totalSpend = filteredLogs.reduce(0) { $0 + ($1.price ?? 0) }
        
        return MonthlySummary(
            totalCups: totalCups,
            totalCalories: totalCalories,
            totalSugar: totalSugar,
            totalSpend: totalSpend
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        Text(String(localized: "this_week")).tag(TimePeriod.weekly)
                        Text(String(localized: "this_month")).tag(TimePeriod.monthly)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    MonthlySummaryCard(summary: periodSummary)
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

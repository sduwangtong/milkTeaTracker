//
//  TrendsView.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct TrendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    
    @Query(sort: \DrinkLog.timestamp, order: .reverse)
    private var allLogs: [DrinkLog]
    
    @Query private var goals: [UserGoals]
    
    @State private var selectedPeriod: TimePeriod = .weekly
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    private var filteredLogs: [DrinkLog] {
        switch selectedPeriod {
        case .weekly:
            return allLogs.currentWeek()
        case .monthly:
            return allLogs.currentMonth()
        }
    }
    
    private var trendSummary: TrendSummary {
        let logs = filteredLogs
        let totalCups = logs.count
        let days: Double = selectedPeriod == .weekly ? 7 : 30
        let averagePerDay = totalCups > 0 ? Double(totalCups) / days : 0
        let totalCalories = logs.reduce(0) { $0 + $1.calories }
        let totalSugar = logs.reduce(0) { $0 + $1.sugarGrams }
        let totalSpend = logs.reduce(0) { $0 + ($1.price ?? 0) }
        
        // Find favorite brand
        let brandCounts = Dictionary(grouping: logs) { $0.brandId }
            .mapValues { $0.count }
        
        let favoriteBrand: (name: String, nameZH: String, emoji: String, count: Int)? = {
            guard let (brandId, count) = brandCounts.max(by: { $0.value < $1.value }),
                  let log = logs.first(where: { $0.brandId == brandId }) else {
                return nil
            }
            return (log.brandName, log.brandNameZH, log.brandEmoji, count)
        }()
        
        return TrendSummary(
            timePeriod: selectedPeriod,
            totalCups: totalCups,
            averagePerDay: averagePerDay,
            totalCalories: totalCalories,
            totalSugar: totalSugar,
            totalSpend: totalSpend,
            favoriteBrand: favoriteBrand
        )
    }
    
    private var trendPoints: [TrendPoint] {
        switch selectedPeriod {
        case .weekly:
            return filteredLogs.groupedByWeekday()
        case .monthly:
            return filteredLogs.groupedByMonthDay()
        }
    }
    
    private var brandBreakdown: [BrandBreakdown] {
        filteredLogs.brandBreakdown()
    }
    
    private var userGoals: UserGoals? {
        goals.first
    }
    
    /// Cup goal - only shown when viewing weekly (goal is always weekly)
    private var cupGoal: Int? {
        guard selectedPeriod == .weekly else { return nil }
        return userGoals?.weeklyCupGoal
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
                    
                    TrendSummaryCard(
                        summary: trendSummary,
                        cupGoal: cupGoal
                    )
                    .padding(.horizontal)
                    
                    DrinkTrendChart(points: trendPoints, period: selectedPeriod)
                        .padding(.horizontal)
                    
                    BrandBreakdownSection(breakdown: brandBreakdown)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle(String(localized: "trends"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveToPhotos) {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .disabled(trendSummary.totalCups == 0)
                }
            }
            .alert(errorMessage, isPresented: $showError) {
                Button(String(localized: "ok"), role: .cancel) { }
            }
            .alert(successMessage, isPresented: $showSuccess) {
                Button(String(localized: "ok"), role: .cancel) { }
            }
        }
    }
    
    private func saveToPhotos() {
        guard trendSummary.totalCups > 0 else { return }
        
        guard let image = ShareImageGenerator.generateImage(
            from: trendSummary,
            languageManager: languageManager,
            cupGoal: cupGoal
        ) else {
            errorMessage = String(localized: "share_error_message")
            showError = true
            return
        }
        
        PhotoLibraryManager.saveImage(image) { result in
            switch result {
            case .success:
                successMessage = String(localized: "photo_saved_success")
                showSuccess = true
                
            case .permissionDenied:
                errorMessage = String(localized: "photo_permission_denied")
                showError = true
                
            case .saveFailed(_):
                errorMessage = String(localized: "photo_save_failed")
                showError = true
            }
        }
    }
}

#Preview {
    TrendsView()
        .environment(LanguageManager.shared)
        .modelContainer(for: [Brand.self, DrinkTemplate.self, DrinkLog.self, UserGoals.self])
}

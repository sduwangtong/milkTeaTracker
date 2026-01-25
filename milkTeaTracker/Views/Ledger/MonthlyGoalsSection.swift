//
//  MonthlyGoalsSection.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct GoalSection: View {
    let currentCups: Int
    @Bindable var goals: UserGoals
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    
    @State private var editingCupGoal = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header - always weekly
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .foregroundStyle(.secondary)
                Text(languageManager.localizedString("weekly_goal"))
                    .font(.system(size: 16, weight: .medium))
            }
            
            // Goal progress
            GoalProgressRow(
                title: "cups_limit",
                current: currentCups,
                goal: goals.weeklyCupGoal,
                unit: "cups",
                color: .green,
                isEditing: $editingCupGoal,
                onSave: { newGoal in
                    goals.weeklyCupGoal = newGoal
                    goals.lastUpdated = Date()
                    try? modelContext.save()
                }
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// Keep old name for compatibility during transition
typealias MonthlyGoalsSection = GoalSection

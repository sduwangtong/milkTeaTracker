//
//  MonthlyGoalsSection.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct MonthlyGoalsSection: View {
    let summary: MonthlySummary
    @Bindable var goals: UserGoals
    let period: TimePeriod
    @Environment(\.modelContext) private var modelContext
    
    @State private var editingCupGoal = false
    @State private var editingCalorieGoal = false
    
    private var goalTitle: String {
        period == .weekly ? String(localized: "weekly_goals") : String(localized: "monthly_goals")
    }
    
    private var cupGoal: Int? {
        period == .weekly ? goals.weeklyCupGoal : goals.monthlyCupGoal
    }
    
    private var calorieGoal: Double? {
        period == .weekly ? goals.weeklyCalorieGoal : goals.monthlyCalorieGoal
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(.secondary)
                Text(goalTitle)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            VStack(spacing: 24) {
                GoalProgressRow(
                    title: "total_cups",
                    current: summary.totalCups,
                    goal: cupGoal,
                    unit: "cups",
                    color: .green,
                    isEditing: $editingCupGoal,
                    onSave: { newGoal in
                        if period == .weekly {
                            goals.weeklyCupGoal = newGoal
                        } else {
                            goals.monthlyCupGoal = newGoal
                        }
                        goals.lastUpdated = Date()
                        try? modelContext.save()
                    }
                )
                
                GoalProgressRow(
                    title: "total_calories",
                    current: Int(summary.totalCalories),
                    goal: calorieGoal.map(Int.init),
                    unit: "kcal",
                    color: .blue,
                    isEditing: $editingCalorieGoal,
                    onSave: { newGoal in
                        if period == .weekly {
                            goals.weeklyCalorieGoal = Double(newGoal)
                        } else {
                            goals.monthlyCalorieGoal = Double(newGoal)
                        }
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
}

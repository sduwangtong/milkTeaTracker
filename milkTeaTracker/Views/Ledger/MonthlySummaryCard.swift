//
//  MonthlySummaryCard.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct MonthlySummary {
    let totalCups: Int
    let totalCalories: Double
    let totalSugar: Double
    let totalSpend: Double
    let longestTeaFreeStreak: Int
}

struct MonthlySummaryCard: View {
    let summary: MonthlySummary
    let period: TimePeriod
    let cupGoal: Int?
    @Environment(LanguageManager.self) private var languageManager
    
    private var isOverGoal: Bool {
        guard let goal = cupGoal else { return false }
        return summary.totalCups > goal
    }
    
    private var progress: Double {
        guard let goal = cupGoal, goal > 0 else { return 0 }
        return min(Double(summary.totalCups) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Emoji changes based on goal status
            Text(isOverGoal ? "😢" : "🧋")
                .font(.system(size: 60))
            
            // Large cup count
            Text("\(summary.totalCups)")
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(.white)
            
            // Progress bar and goal indicator (only when goal is set)
            if let goal = cupGoal {
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .tint(isOverGoal ? .red : .white)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 4) {
                        Text("\(summary.totalCups)/\(goal)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                        
                        if isOverGoal {
                            Text("⚠️")
                                .font(.system(size: 12))
                        }
                    }
                }
            }
            
            // "Cups this week/month"
            Text(languageManager.localizedString(period == .weekly ? "cups_this_week" : "cups_this_month"))
                .font(.system(size: 18))
                .foregroundStyle(.white.opacity(0.9))
            
            // Divider
            Rectangle()
                .fill(.white.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
            
            // Three stats in a row
            HStack(spacing: 0) {
                // Total Calories
                VStack(spacing: 4) {
                    Text("\(Int(summary.totalCalories))")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(languageManager.localizedString("total_calories_short"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                
                // Total Sugar
                VStack(spacing: 4) {
                    Text("\(Int(summary.totalSugar))g")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(languageManager.localizedString("total_sugar_short"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                
                // Total Spend
                VStack(spacing: 4) {
                    Text("$\(Int(summary.totalSpend))")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(languageManager.localizedString("total_spend"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
            }
            
            // Longest Tea-Free Streak (only for weekly view)
            if period == .weekly {
                HStack(spacing: 8) {
                    Text("🏆")
                        .font(.system(size: 16))
                    
                    Text(languageManager.localizedString("longest_tea_free_streak"))
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text("\(summary.longestTeaFreeStreak)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(languageManager.localizedString(summary.longestTeaFreeStreak == 1 ? "day" : "days"))
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.5, blue: 0.9),
                    Color(red: 0.6, green: 0.4, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

#Preview("With Goal - Under") {
    MonthlySummaryCard(
        summary: MonthlySummary(
            totalCups: 16,
            totalCalories: 5280,
            totalSugar: 320,
            totalSpend: 288,
            longestTeaFreeStreak: 3
        ),
        period: .weekly,
        cupGoal: 20
    )
    .padding()
}

#Preview("With Goal - Over") {
    MonthlySummaryCard(
        summary: MonthlySummary(
            totalCups: 25,
            totalCalories: 5280,
            totalSugar: 320,
            totalSpend: 288,
            longestTeaFreeStreak: 1
        ),
        period: .weekly,
        cupGoal: 20
    )
    .padding()
}

#Preview("No Goal - Monthly") {
    MonthlySummaryCard(
        summary: MonthlySummary(
            totalCups: 16,
            totalCalories: 5280,
            totalSugar: 320,
            totalSpend: 288,
            longestTeaFreeStreak: 5
        ),
        period: .monthly,
        cupGoal: nil
    )
    .padding()
}

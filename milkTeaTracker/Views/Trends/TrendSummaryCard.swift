//
//  TrendSummaryCard.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct TrendSummaryCard: View {
    let summary: TrendSummary
    let cupGoal: Int?
    @Environment(LanguageManager.self) private var languageManager
    
    private var cupGoalStatus: String? {
        guard let goal = cupGoal else { return nil }
        return summary.totalCups <= goal ? "🎉" : "🚨"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Period label
            Text(summary.timePeriod == .weekly ? String(localized: "this_week") : String(localized: "this_month"))
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.9))
            
            // Large cup count with goal status
            HStack(spacing: 12) {
                Text("\(summary.totalCups)cups")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(.white)
                
                if let status = cupGoalStatus {
                    Text(status)
                        .font(.system(size: 40))
                }
            }
            
            // Average per day
            Text("\(String(localized: "avg_per_day")) \(String(format: "%.1f", summary.averagePerDay)) cups")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.9))
            
            // Divider
            Rectangle()
                .fill(.white.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
            
            // Two-column stats
            HStack(spacing: 40) {
                // Total Calories
                VStack(spacing: 4) {
                    Text("\(Int(summary.totalCalories))")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(String(localized: "total_calories_kcal"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                // Total Sugar
                VStack(spacing: 4) {
                    Text("\(Int(summary.totalSugar))g")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(String(localized: "total_sugar"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            // Favorite Brand
            if let favorite = summary.favoriteBrand {
                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
                
                VStack(spacing: 8) {
                    Text(String(localized: "favorite_brand"))
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    HStack(spacing: 8) {
                        Text(favorite.emoji)
                            .font(.system(size: 24))
                        Text(languageManager.isEnglish ? favorite.name : favorite.nameZH)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.4, blue: 0.9),
                    Color(red: 0.8, green: 0.3, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

#Preview {
    TrendSummaryCard(
        summary: TrendSummary(
            timePeriod: .weekly,
            totalCups: 16,
            averagePerDay: 2.3,
            totalCalories: 5120,
            totalSugar: 320,
            totalSpend: 288,
            favoriteBrand: ("HeyTea", "喜茶", "🍵", 8)
        ),
        cupGoal: 20
    )
    .environment(LanguageManager.shared)
    .padding()
}

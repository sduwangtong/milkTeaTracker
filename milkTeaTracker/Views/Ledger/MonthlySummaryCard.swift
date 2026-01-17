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
}

struct MonthlySummaryCard: View {
    let summary: MonthlySummary
    
    var body: some View {
        VStack(spacing: 20) {
            // Bubble tea emoji
            Text("🧋")
                .font(.system(size: 60))
            
            // Large cup count
            Text("\(summary.totalCups)")
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(.white)
            
            // "Cups this month"
            Text(String(localized: "cups_this_month"))
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
                    
                    Text(String(localized: "total_calories_short"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                
                // Total Sugar
                VStack(spacing: 4) {
                    Text("\(Int(summary.totalSugar))g")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(String(localized: "total_sugar_short"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                
                // Total Spend
                VStack(spacing: 4) {
                    Text("$\(Int(summary.totalSpend))")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(String(localized: "total_spend"))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
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

#Preview {
    MonthlySummaryCard(summary: MonthlySummary(
        totalCups: 16,
        totalCalories: 5280,
        totalSugar: 320,
        totalSpend: 288
    ))
    .padding()
}

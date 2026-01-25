//
//  TrendMiniChart.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/22/26.
//

import SwiftUI
import Charts

struct TrendMiniChart: View {
    let periodData: [PeriodCupCount]
    let period: TimePeriod
    @Environment(LanguageManager.self) private var languageManager
    
    private var trendDiff: Int {
        guard periodData.count >= 2 else { return 0 }
        let current = periodData.last?.cups ?? 0
        let previous = periodData[periodData.count - 2].cups
        return current - previous
    }
    
    private func comparisonText() -> String? {
        guard periodData.count >= 2 else { return nil }
        
        if trendDiff == 0 {
            return languageManager.localizedString("same_as_last")
        } else if trendDiff > 0 {
            return languageManager.localizedString("more_than_last", args: trendDiff)
        } else {
            return languageManager.localizedString("less_than_last", args: abs(trendDiff))
        }
    }
    
    private var trendIcon: String {
        guard periodData.count >= 2 else { return "" }
        
        if trendDiff == 0 {
            return "→"
        } else if trendDiff > 0 {
            return "↑"
        } else {
            return "↓"
        }
    }
    
    private var trendColor: Color {
        guard periodData.count >= 2 else { return .secondary }
        
        // Lower cups = good (green), higher = warning (orange)
        if trendDiff == 0 {
            return .secondary
        } else if trendDiff > 0 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func periodTitle() -> String {
        period == .weekly 
            ? languageManager.localizedString("last_4_weeks") 
            : languageManager.localizedString("last_4_months")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with trend comparison
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(.secondary)
                    Text(periodTitle())
                        .font(.system(size: 16, weight: .medium))
                }
                
                Spacer()
                
                if let comparison = comparisonText() {
                    HStack(spacing: 4) {
                        Text(trendIcon)
                            .font(.system(size: 14, weight: .bold))
                        Text(comparison)
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(trendColor)
                }
            }
            
            // Mini bar chart
            Chart(periodData) { item in
                BarMark(
                    x: .value("Period", item.label),
                    y: .value("Cups", item.cups)
                )
                .foregroundStyle(
                    item.isCurrentPeriod 
                        ? Color(red: 0.6, green: 0.4, blue: 0.9)
                        : Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.5)
                )
                .cornerRadius(4)
                
                // Add cup count label on top of each bar
                if item.cups > 0 {
                    PointMark(
                        x: .value("Period", item.label),
                        y: .value("Cups", item.cups)
                    )
                    .annotation(position: .top) {
                        Text("\(item.cups)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .opacity(0)
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.system(size: 12))
                }
            }
            .frame(height: 100)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview("Weekly Trend") {
    let sampleData = [
        PeriodCupCount(label: "W1", cups: 8, periodStart: Date(), isCurrentPeriod: false),
        PeriodCupCount(label: "W2", cups: 12, periodStart: Date(), isCurrentPeriod: false),
        PeriodCupCount(label: "W3", cups: 6, periodStart: Date(), isCurrentPeriod: false),
        PeriodCupCount(label: "W4", cups: 9, periodStart: Date(), isCurrentPeriod: true)
    ]
    
    return TrendMiniChart(periodData: sampleData, period: .weekly)
        .padding()
        .environment(LanguageManager.shared)
}

#Preview("Monthly Trend") {
    let sampleData = [
        PeriodCupCount(label: "Oct", cups: 32, periodStart: Date(), isCurrentPeriod: false),
        PeriodCupCount(label: "Nov", cups: 28, periodStart: Date(), isCurrentPeriod: false),
        PeriodCupCount(label: "Dec", cups: 35, periodStart: Date(), isCurrentPeriod: false),
        PeriodCupCount(label: "Jan", cups: 22, periodStart: Date(), isCurrentPeriod: true)
    ]
    
    return TrendMiniChart(periodData: sampleData, period: .monthly)
        .padding()
        .environment(LanguageManager.shared)
}

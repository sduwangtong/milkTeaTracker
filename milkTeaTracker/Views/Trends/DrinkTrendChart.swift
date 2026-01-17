//
//  DrinkTrendChart.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import Charts

struct DrinkTrendChart: View {
    let points: [TrendPoint]
    let period: TimePeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.secondary)
                Text(String(localized: "drink_trend"))
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Chart(points) { point in
                BarMark(
                    x: .value("Day", point.date, unit: .day),
                    y: .value("Cups", point.cups)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.9),
                            Color(red: 0.7, green: 0.35, blue: 0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(8)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            if period == .weekly {
                                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                            } else {
                                Text(date.formatted(.dateTime.day()))
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 200)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let points = (0..<7).map { day in
        TrendPoint(
            date: calendar.date(byAdding: .day, value: -6 + day, to: today)!,
            cups: Int.random(in: 0...4),
            calories: Double.random(in: 0...1000),
            spend: Double.random(in: 0...50)
        )
    }
    
    return DrinkTrendChart(points: points, period: .weekly)
        .padding()
}

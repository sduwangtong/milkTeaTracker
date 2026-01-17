//
//  TrendModels.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation

enum TimePeriod {
    case weekly
    case monthly
}

struct TrendSummary {
    let timePeriod: TimePeriod
    let totalCups: Int
    let averagePerDay: Double
    let totalCalories: Double
    let totalSugar: Double
    let totalSpend: Double
    let favoriteBrand: (name: String, nameZH: String, emoji: String, count: Int)?
}

struct TrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let cups: Int
    let calories: Double
    let spend: Double
}

struct BrandBreakdown: Identifiable {
    let id = UUID()
    let brandId: UUID
    let brandName: String
    let brandNameZH: String
    let brandEmoji: String
    let cupCount: Int
    let totalSpend: Double
    let percentage: Double
}

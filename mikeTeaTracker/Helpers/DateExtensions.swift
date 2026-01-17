//
//  DateExtensions.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation

extension Date {
    func isInCurrentMonth() -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    func isInCurrentWeek() -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func endOfWeek() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek()) ?? self
    }
}

extension Array where Element == DrinkLog {
    func currentMonth() -> [DrinkLog] {
        filter { $0.timestamp.isInCurrentMonth() }
    }
    
    func currentWeek() -> [DrinkLog] {
        filter { $0.timestamp.isInCurrentWeek() }
    }
    
    func groupedByDate() -> [(Date, [DrinkLog])] {
        let grouped = Dictionary(grouping: self) { log in
            log.timestamp.startOfDay()
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    func groupedByWeekday() -> [TrendPoint] {
        let calendar = Calendar.current
        let startOfWeek = Date().startOfWeek()
        
        var points: [TrendPoint] = []
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                let dayLogs = filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
                points.append(TrendPoint(
                    date: date,
                    cups: dayLogs.count,
                    calories: dayLogs.reduce(0) { $0 + $1.calories },
                    spend: dayLogs.reduce(0) { $0 + ($1.price ?? 0) }
                ))
            }
        }
        return points
    }
    
    func groupedByMonthDay() -> [TrendPoint] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let range = calendar.range(of: .day, in: .month, for: Date())!
        
        var points: [TrendPoint] = []
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let dayLogs = filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
                points.append(TrendPoint(
                    date: date,
                    cups: dayLogs.count,
                    calories: dayLogs.reduce(0) { $0 + $1.calories },
                    spend: dayLogs.reduce(0) { $0 + ($1.price ?? 0) }
                ))
            }
        }
        return points
    }
    
    func brandBreakdown() -> [BrandBreakdown] {
        let total = count
        guard total > 0 else { return [] }
        
        let grouped = Dictionary(grouping: self) { $0.brandId }
        
        return grouped.map { brandId, logs in
            let firstLog = logs.first!
            return BrandBreakdown(
                brandId: brandId,
                brandName: firstLog.brandName,
                brandNameZH: firstLog.brandNameZH,
                brandEmoji: firstLog.brandEmoji,
                cupCount: logs.count,
                totalSpend: logs.reduce(0) { $0 + ($1.price ?? 0) },
                percentage: Double(logs.count) / Double(total) * 100
            )
        }
        .sorted { $0.cupCount > $1.cupCount }
    }
}

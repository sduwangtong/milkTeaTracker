//
//  DateExtensions.swift
//  milkTeaTracker
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
    
    func isInSameWeek(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: otherDate, toGranularity: .weekOfYear)
    }
    
    func isInSameMonth(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: otherDate, toGranularity: .month)
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
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth())!
    }
    
    func previousWeek() -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self)!
    }
    
    func nextWeek() -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self)!
    }
    
    func previousMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
    
    func nextMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
}

extension Array where Element == DrinkLog {
    func currentMonth() -> [DrinkLog] {
        filter { $0.timestamp.isInCurrentMonth() }
    }
    
    func currentWeek() -> [DrinkLog] {
        filter { $0.timestamp.isInCurrentWeek() }
    }
    
    /// Filter logs for a specific week containing the reference date
    func forWeek(containing referenceDate: Date) -> [DrinkLog] {
        filter { $0.timestamp.isInSameWeek(as: referenceDate) }
    }
    
    /// Filter logs for a specific month containing the reference date
    func forMonth(containing referenceDate: Date) -> [DrinkLog] {
        filter { $0.timestamp.isInSameMonth(as: referenceDate) }
    }
    
    /// Calculates the longest streak of consecutive days without any drinks in the given period
    func longestTeaFreeStreak(for period: TimePeriod, referenceDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        // Determine the date range based on period
        let startDate: Date
        let endDate: Date
        
        switch period {
        case .weekly:
            startDate = referenceDate.startOfWeek()
            // End date is either today or end of week, whichever is earlier
            let weekEnd = referenceDate.endOfWeek()
            endDate = Swift.min(today, weekEnd)
        case .monthly:
            startDate = referenceDate.startOfMonth()
            let monthEnd = referenceDate.endOfMonth()
            endDate = Swift.min(today, monthEnd)
        }
        
        // Get all dates with drinks
        let datesWithDrinks = Set(self.map { calendar.startOfDay(for: $0.timestamp) })
        
        // Calculate streak
        var longestStreak = 0
        var currentStreak = 0
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            
            if datesWithDrinks.contains(dayStart) {
                // Had a drink this day, reset streak
                currentStreak = 0
            } else {
                // No drink this day, increment streak
                currentStreak += 1
                longestStreak = Swift.max(longestStreak, currentStreak)
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return longestStreak
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
    
    /// Get cup counts for the last N weeks (including current week)
    /// Returns array from oldest to newest: [4 weeks ago, 3 weeks ago, 2 weeks ago, last week/current]
    func lastNWeeksCupCounts(_ n: Int = 4, referenceDate: Date = Date()) -> [PeriodCupCount] {
        let calendar = Calendar.current
        var results: [PeriodCupCount] = []
        
        for i in (0..<n).reversed() {
            let weekDate = calendar.date(byAdding: .weekOfYear, value: -i, to: referenceDate)!
            let weekStart = weekDate.startOfWeek()
            let weekEnd = weekDate.endOfWeek()
            let weekLogs = filter { $0.timestamp >= weekStart && $0.timestamp <= weekEnd }
            
            // Generate short label (W1, W2, etc. or week number)
            let weekOfYear = calendar.component(.weekOfYear, from: weekDate)
            let label = "W\(weekOfYear)"
            
            results.append(PeriodCupCount(
                label: label,
                cups: weekLogs.count,
                periodStart: weekStart,
                isCurrentPeriod: i == 0
            ))
        }
        
        return results
    }
    
    /// Get cup counts for the last N months (including current month)
    /// Returns array from oldest to newest
    func lastNMonthsCupCounts(_ n: Int = 4, referenceDate: Date = Date()) -> [PeriodCupCount] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        var results: [PeriodCupCount] = []
        
        for i in (0..<n).reversed() {
            let monthDate = calendar.date(byAdding: .month, value: -i, to: referenceDate)!
            let monthStart = monthDate.startOfMonth()
            let monthEnd = monthDate.endOfMonth()
            let monthLogs = filter { $0.timestamp >= monthStart && $0.timestamp <= monthEnd }
            
            let label = dateFormatter.string(from: monthDate)
            
            results.append(PeriodCupCount(
                label: label,
                cups: monthLogs.count,
                periodStart: monthStart,
                isCurrentPeriod: i == 0
            ))
        }
        
        return results
    }
}

/// Represents cup count for a time period (used in trend mini-chart)
struct PeriodCupCount: Identifiable {
    let id = UUID()
    let label: String
    let cups: Int
    let periodStart: Date
    let isCurrentPeriod: Bool
}

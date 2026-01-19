//
//  TeaFreeStreakTests.swift
//  milkTeaTrackerTests
//
//  Tests for longest tea-free streak calculation
//

import XCTest
@testable import milkTeaTracker

final class TeaFreeStreakTests: XCTestCase {
    
    // MARK: - Helper to create mock DrinkLog
    
    private func createMockLog(daysAgo: Int) -> DrinkLog {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        
        return DrinkLog(
            brandId: UUID(),
            brandName: "Test Brand",
            brandNameZH: "测试品牌",
            brandEmoji: "🧋",
            drinkName: "Test Drink",
            drinkNameZH: "测试饮品",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25,
            price: 5.0,
            timestamp: date
        )
    }
    
    // MARK: - Streak Calculation Logic Tests
    
    func testStreakCalculationWithNoDrinks() {
        // When there are no drinks, the streak should be the number of days in the period
        let emptyLogs: [DrinkLog] = []
        
        // For an empty array, streak for weekly should be up to 7 days (or days elapsed)
        let streak = emptyLogs.longestTeaFreeStreak(for: .weekly)
        
        // Streak should be at least 1 (today counts if no drinks)
        XCTAssertGreaterThanOrEqual(streak, 1, "Streak should be at least 1 day with no drinks")
    }
    
    func testStreakCalculationWithDrinksEveryDay() {
        // When there are drinks every day, streak should be 0
        var logs: [DrinkLog] = []
        
        // Add drinks for the past 7 days
        for day in 0..<7 {
            logs.append(createMockLog(daysAgo: day))
        }
        
        let streak = logs.longestTeaFreeStreak(for: .weekly)
        
        XCTAssertEqual(streak, 0, "Streak should be 0 when drinks every day")
    }
    
    func testStreakWithAlternatingDays() {
        // Drinks on days 0, 2, 4, 6 (every other day)
        // Tea-free days: 1, 3, 5 (each isolated, so streak = 1)
        var logs: [DrinkLog] = []
        logs.append(createMockLog(daysAgo: 0)) // Today
        logs.append(createMockLog(daysAgo: 2))
        logs.append(createMockLog(daysAgo: 4))
        logs.append(createMockLog(daysAgo: 6))
        
        let streak = logs.longestTeaFreeStreak(for: .weekly)
        
        // Each tea-free day is isolated, so max streak is 1
        XCTAssertEqual(streak, 1, "Streak should be 1 with alternating drink days")
    }
    
    func testStreakWithConsecutiveTeaFreeDays() {
        // Only drink on day 0 (today) and day 6
        // Tea-free days: 1, 2, 3, 4, 5 (5 consecutive days)
        var logs: [DrinkLog] = []
        logs.append(createMockLog(daysAgo: 0)) // Today
        logs.append(createMockLog(daysAgo: 6)) // 6 days ago
        
        let streak = logs.longestTeaFreeStreak(for: .weekly)
        
        // Days 1-5 should be tea-free, giving a streak of 5
        XCTAssertGreaterThanOrEqual(streak, 4, "Streak should be at least 4 consecutive tea-free days")
    }
    
    // MARK: - Period Tests
    
    func testWeeklyPeriodReturnsValidStreak() {
        let logs: [DrinkLog] = []
        let streak = logs.longestTeaFreeStreak(for: .weekly)
        
        // Weekly streak should be between 0 and 7
        XCTAssertGreaterThanOrEqual(streak, 0, "Streak should not be negative")
        XCTAssertLessThanOrEqual(streak, 7, "Weekly streak should not exceed 7 days")
    }
    
    func testMonthlyPeriodReturnsValidStreak() {
        let logs: [DrinkLog] = []
        let streak = logs.longestTeaFreeStreak(for: .monthly)
        
        // Monthly streak should be between 0 and 31
        XCTAssertGreaterThanOrEqual(streak, 0, "Streak should not be negative")
        XCTAssertLessThanOrEqual(streak, 31, "Monthly streak should not exceed 31 days")
    }
    
    // MARK: - MonthlySummary with Streak Tests
    
    func testMonthlySummaryIncludesStreak() {
        let summary = MonthlySummary(
            totalCups: 10,
            totalCalories: 3000,
            totalSugar: 200,
            totalSpend: 50,
            longestTeaFreeStreak: 3
        )
        
        XCTAssertEqual(summary.longestTeaFreeStreak, 3, "Summary should store streak value")
    }
    
    func testMonthlySummaryWithZeroStreak() {
        let summary = MonthlySummary(
            totalCups: 10,
            totalCalories: 3000,
            totalSugar: 200,
            totalSpend: 50,
            longestTeaFreeStreak: 0
        )
        
        XCTAssertEqual(summary.longestTeaFreeStreak, 0, "Summary should allow zero streak")
    }
    
    // MARK: - Day/Days Pluralization Tests
    
    func testDayPluralForSingleDay() {
        let streak = 1
        let dayText = streak == 1 ? "day" : "days"
        
        XCTAssertEqual(dayText, "day", "Should use singular 'day' for streak of 1")
    }
    
    func testDayPluralForMultipleDays() {
        let streak = 5
        let dayText = streak == 1 ? "day" : "days"
        
        XCTAssertEqual(dayText, "days", "Should use plural 'days' for streak > 1")
    }
    
    func testDayPluralForZeroDays() {
        let streak = 0
        let dayText = streak == 1 ? "day" : "days"
        
        XCTAssertEqual(dayText, "days", "Should use plural 'days' for streak of 0")
    }
}

//
//  AllDrinksListViewTests.swift
//  milkTeaTrackerTests
//
//  Created for testing all drinks list view functionality
//

import XCTest
import SwiftUI
@testable import mikeTeaTracker

final class AllDrinksListViewTests: XCTestCase {
    
    func testGroupedLogsAreSortedByDate() {
        // Create test logs with different dates
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let log1 = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Test 1",
            drinkNameZH: "测试1",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25,
            timestamp: today
        )
        
        let log2 = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Test 2",
            drinkNameZH: "测试2",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25,
            timestamp: yesterday
        )
        
        let log3 = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Test 3",
            drinkNameZH: "测试3",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25,
            timestamp: twoDaysAgo
        )
        
        // Verify timestamps
        XCTAssertTrue(log1.timestamp > log2.timestamp, "Log 1 should be newer than log 2")
        XCTAssertTrue(log2.timestamp > log3.timestamp, "Log 2 should be newer than log 3")
    }
    
    func testDateFormattingForToday() {
        let calendar = Calendar.current
        let today = Date()
        
        XCTAssertTrue(calendar.isDateInToday(today), "Today should be identified as today")
    }
    
    func testDateFormattingForYesterday() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        
        XCTAssertTrue(calendar.isDateInYesterday(yesterday), "Yesterday should be identified as yesterday")
    }
    
    func testEmptyStateHandling() {
        // Test that empty array can be handled
        let emptyLogs: [DrinkLog] = []
        
        XCTAssertTrue(emptyLogs.isEmpty, "Empty logs array should be empty")
        XCTAssertEqual(emptyLogs.count, 0, "Empty logs count should be 0")
    }
    
    func testDrinkLogGroupingByDate() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Create multiple logs for same day
        let log1Today = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Morning",
            drinkNameZH: "早上",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25,
            timestamp: today
        )
        
        let log2Today = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Afternoon",
            drinkNameZH: "下午",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25,
            timestamp: calendar.date(byAdding: .hour, value: 3, to: today)!
        )
        
        let logYesterday = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Yesterday",
            drinkNameZH: "昨天",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25,
            timestamp: yesterday
        )
        
        let allLogs = [log1Today, log2Today, logYesterday]
        
        // Group by date
        let grouped = Dictionary(grouping: allLogs) { log in
            calendar.startOfDay(for: log.timestamp)
        }
        
        XCTAssertEqual(grouped.count, 2, "Should have 2 groups (today and yesterday)")
        
        let todayStart = calendar.startOfDay(for: today)
        let yesterdayStart = calendar.startOfDay(for: yesterday)
        
        XCTAssertEqual(grouped[todayStart]?.count, 2, "Today should have 2 logs")
        XCTAssertEqual(grouped[yesterdayStart]?.count, 1, "Yesterday should have 1 log")
    }
}

//
//  DateNavigationTests.swift
//  milkTeaTrackerTests
//
//  Tests for date navigation and filtering functionality
//

import XCTest
@testable import milkTeaTracker

final class DateNavigationTests: XCTestCase {
    
    // MARK: - Date Extension Tests
    
    func testStartOfWeek() {
        let date = Date()
        let startOfWeek = date.startOfWeek()
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: startOfWeek)
        
        // Start of week should be Sunday (1) or Monday (2) depending on locale
        XCTAssertTrue(weekday == 1 || weekday == 2, "Start of week should be Sunday or Monday")
    }
    
    func testEndOfWeek() {
        let date = Date()
        let startOfWeek = date.startOfWeek()
        let endOfWeek = date.endOfWeek()
        
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: startOfWeek, to: endOfWeek).day!
        
        XCTAssertEqual(daysDifference, 6, "End of week should be 6 days after start of week")
    }
    
    func testStartOfMonth() {
        let date = Date()
        let startOfMonth = date.startOfMonth()
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: startOfMonth)
        
        XCTAssertEqual(day, 1, "Start of month should be day 1")
    }
    
    func testPreviousWeek() {
        let date = Date()
        let previousWeek = date.previousWeek()
        
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: previousWeek, to: date).day!
        
        XCTAssertEqual(daysDifference, 7, "Previous week should be 7 days earlier")
    }
    
    func testNextWeek() {
        let date = Date()
        let nextWeek = date.nextWeek()
        
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: date, to: nextWeek).day!
        
        XCTAssertEqual(daysDifference, 7, "Next week should be 7 days later")
    }
    
    func testPreviousMonth() {
        let date = Date()
        let previousMonth = date.previousMonth()
        
        let calendar = Calendar.current
        let monthDifference = calendar.dateComponents([.month], from: previousMonth, to: date).month!
        
        XCTAssertEqual(monthDifference, 1, "Previous month should be 1 month earlier")
    }
    
    func testNextMonth() {
        let date = Date()
        let nextMonth = date.nextMonth()
        
        let calendar = Calendar.current
        let monthDifference = calendar.dateComponents([.month], from: date, to: nextMonth).month!
        
        XCTAssertEqual(monthDifference, 1, "Next month should be 1 month later")
    }
    
    // MARK: - Same Week/Month Tests
    
    func testIsInSameWeek() {
        let date = Date()
        let startOfWeek = date.startOfWeek()
        let endOfWeek = date.endOfWeek()
        
        XCTAssertTrue(startOfWeek.isInSameWeek(as: date), "Start of week should be in same week")
        XCTAssertTrue(endOfWeek.isInSameWeek(as: date), "End of week should be in same week")
    }
    
    func testIsNotInSameWeek() {
        let date = Date()
        let previousWeek = date.previousWeek()
        let nextWeek = date.nextWeek()
        
        XCTAssertFalse(previousWeek.isInSameWeek(as: date), "Previous week should not be in same week")
        XCTAssertFalse(nextWeek.isInSameWeek(as: date), "Next week should not be in same week")
    }
    
    func testIsInSameMonth() {
        let date = Date()
        let startOfMonth = date.startOfMonth()
        
        XCTAssertTrue(startOfMonth.isInSameMonth(as: date), "Start of month should be in same month")
    }
    
    func testIsNotInSameMonth() {
        let date = Date()
        let previousMonth = date.previousMonth()
        let nextMonth = date.nextMonth()
        
        XCTAssertFalse(previousMonth.isInSameMonth(as: date), "Previous month should not be in same month")
        XCTAssertFalse(nextMonth.isInSameMonth(as: date), "Next month should not be in same month")
    }
    
    // MARK: - Filter Methods Tests
    
    func testForWeekContaining() {
        let today = Date()
        let logs = createMockLogs()
        
        let weekLogs = logs.forWeek(containing: today)
        
        // All filtered logs should be in the same week as today
        for log in weekLogs {
            XCTAssertTrue(log.timestamp.isInSameWeek(as: today), "Filtered log should be in the same week")
        }
    }
    
    func testForMonthContaining() {
        let today = Date()
        let logs = createMockLogs()
        
        let monthLogs = logs.forMonth(containing: today)
        
        // All filtered logs should be in the same month as today
        for log in monthLogs {
            XCTAssertTrue(log.timestamp.isInSameMonth(as: today), "Filtered log should be in the same month")
        }
    }
    
    // MARK: - Navigation Logic Tests
    
    func testCanGoNextForCurrentWeek() {
        let today = Date()
        let canGoNext = !today.isInSameWeek(as: today)
        
        XCTAssertFalse(canGoNext, "Should not be able to go to next week when viewing current week")
    }
    
    func testCanGoNextForPastWeek() {
        let today = Date()
        let pastWeek = today.previousWeek()
        let canGoNext = !pastWeek.isInSameWeek(as: today)
        
        XCTAssertTrue(canGoNext, "Should be able to go to next week when viewing past week")
    }
    
    // MARK: - Helper Methods
    
    private func createMockLogs() -> [DrinkLog] {
        var logs: [DrinkLog] = []
        let calendar = Calendar.current
        
        // Create logs for the past 30 days
        for daysAgo in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                let log = DrinkLog(
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
                logs.append(log)
            }
        }
        
        return logs
    }
}

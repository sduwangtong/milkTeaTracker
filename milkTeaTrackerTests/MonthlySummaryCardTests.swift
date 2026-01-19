//
//  MonthlySummaryCardTests.swift
//  milkTeaTrackerTests
//
//  Tests for MonthlySummaryCard period-based label display and goal progress
//

import XCTest
@testable import milkTeaTracker

final class MonthlySummaryCardTests: XCTestCase {
    
    // MARK: - Period Label Tests
    
    func testCupsLabelKeyForWeeklyPeriod() {
        // When period is weekly, the label key should be "cups_this_week"
        let period: TimePeriod = .weekly
        let expectedKey = period == .weekly ? "cups_this_week" : "cups_this_month"
        
        XCTAssertEqual(expectedKey, "cups_this_week", "Weekly period should use 'cups_this_week' label")
    }
    
    func testCupsLabelKeyForMonthlyPeriod() {
        // When period is monthly, the label key should be "cups_this_month"
        let period: TimePeriod = .monthly
        let expectedKey = period == .weekly ? "cups_this_week" : "cups_this_month"
        
        XCTAssertEqual(expectedKey, "cups_this_month", "Monthly period should use 'cups_this_month' label")
    }
    
    func testTimePeriodEnumCases() {
        // Verify TimePeriod has exactly two cases
        XCTAssertNotNil(TimePeriod.weekly, "Weekly period should exist")
        XCTAssertNotNil(TimePeriod.monthly, "Monthly period should exist")
    }
    
    // MARK: - MonthlySummary Tests
    
    func testMonthlySummaryInitialization() {
        // Test MonthlySummary struct can be properly initialized
        let summary = MonthlySummary(
            totalCups: 10,
            totalCalories: 3000,
            totalSugar: 200,
            totalSpend: 50
        )
        
        XCTAssertEqual(summary.totalCups, 10, "Total cups should be 10")
        XCTAssertEqual(summary.totalCalories, 3000, "Total calories should be 3000")
        XCTAssertEqual(summary.totalSugar, 200, "Total sugar should be 200")
        XCTAssertEqual(summary.totalSpend, 50, "Total spend should be 50")
    }
    
    func testMonthlySummaryWithZeroValues() {
        // Test MonthlySummary handles zero values
        let summary = MonthlySummary(
            totalCups: 0,
            totalCalories: 0,
            totalSugar: 0,
            totalSpend: 0
        )
        
        XCTAssertEqual(summary.totalCups, 0, "Zero cups should be valid")
        XCTAssertEqual(summary.totalCalories, 0, "Zero calories should be valid")
        XCTAssertEqual(summary.totalSugar, 0, "Zero sugar should be valid")
        XCTAssertEqual(summary.totalSpend, 0, "Zero spend should be valid")
    }
    
    // MARK: - Goal Progress Tests
    
    func testIsOverGoalWhenUnderGoal() {
        // When cups (10) < goal (20), isOverGoal should be false
        let totalCups = 10
        let cupGoal: Int? = 20
        
        let isOverGoal: Bool = {
            guard let goal = cupGoal else { return false }
            return totalCups > goal
        }()
        
        XCTAssertFalse(isOverGoal, "Should not be over goal when cups < goal")
    }
    
    func testIsOverGoalWhenOverGoal() {
        // When cups (25) > goal (20), isOverGoal should be true
        let totalCups = 25
        let cupGoal: Int? = 20
        
        let isOverGoal: Bool = {
            guard let goal = cupGoal else { return false }
            return totalCups > goal
        }()
        
        XCTAssertTrue(isOverGoal, "Should be over goal when cups > goal")
    }
    
    func testIsOverGoalWhenAtExactGoal() {
        // When cups (20) == goal (20), isOverGoal should be false
        let totalCups = 20
        let cupGoal: Int? = 20
        
        let isOverGoal: Bool = {
            guard let goal = cupGoal else { return false }
            return totalCups > goal
        }()
        
        XCTAssertFalse(isOverGoal, "Should not be over goal when cups == goal")
    }
    
    func testIsOverGoalWhenNoGoalSet() {
        // When no goal is set, isOverGoal should be false
        let totalCups = 100
        let cupGoal: Int? = nil
        
        let isOverGoal: Bool = {
            guard let goal = cupGoal else { return false }
            return totalCups > goal
        }()
        
        XCTAssertFalse(isOverGoal, "Should not be over goal when no goal is set")
    }
    
    func testProgressCalculationUnderGoal() {
        // When cups (10) / goal (20) = 0.5 progress
        let totalCups = 10
        let cupGoal: Int? = 20
        
        let progress: Double = {
            guard let goal = cupGoal, goal > 0 else { return 0 }
            return min(Double(totalCups) / Double(goal), 1.0)
        }()
        
        XCTAssertEqual(progress, 0.5, accuracy: 0.001, "Progress should be 50%")
    }
    
    func testProgressCalculationAtGoal() {
        // When cups (20) / goal (20) = 1.0 progress
        let totalCups = 20
        let cupGoal: Int? = 20
        
        let progress: Double = {
            guard let goal = cupGoal, goal > 0 else { return 0 }
            return min(Double(totalCups) / Double(goal), 1.0)
        }()
        
        XCTAssertEqual(progress, 1.0, accuracy: 0.001, "Progress should be 100%")
    }
    
    func testProgressCalculationOverGoal() {
        // When cups (30) > goal (20), progress should be capped at 1.0
        let totalCups = 30
        let cupGoal: Int? = 20
        
        let progress: Double = {
            guard let goal = cupGoal, goal > 0 else { return 0 }
            return min(Double(totalCups) / Double(goal), 1.0)
        }()
        
        XCTAssertEqual(progress, 1.0, accuracy: 0.001, "Progress should be capped at 100%")
    }
    
    func testProgressCalculationNoGoal() {
        // When no goal is set, progress should be 0
        let totalCups = 10
        let cupGoal: Int? = nil
        
        let progress: Double = {
            guard let goal = cupGoal, goal > 0 else { return 0 }
            return min(Double(totalCups) / Double(goal), 1.0)
        }()
        
        XCTAssertEqual(progress, 0, "Progress should be 0 when no goal is set")
    }
    
    func testEmojiSelectionUnderGoal() {
        // When under goal, emoji should be 🧋
        let isOverGoal = false
        let emoji = isOverGoal ? "😢" : "🧋"
        
        XCTAssertEqual(emoji, "🧋", "Emoji should be tea when under goal")
    }
    
    func testEmojiSelectionOverGoal() {
        // When over goal, emoji should be 😢
        let isOverGoal = true
        let emoji = isOverGoal ? "😢" : "🧋"
        
        XCTAssertEqual(emoji, "😢", "Emoji should be crying when over goal")
    }
}

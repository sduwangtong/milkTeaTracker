//
//  SugarLevelTests.swift
//  mikeTeaTrackerTests
//
//  Created for sugar level percentage testing
//

import XCTest
@testable import mikeTeaTracker

final class SugarLevelTests: XCTestCase {
    
    func testSugarLevelMultipliers() {
        // Test that sugar levels match the expected percentages
        XCTAssertEqual(SugarLevel.none.multiplier, 0.0, "None should be 0%")
        XCTAssertEqual(SugarLevel.light.multiplier, 0.3, "Light should be 30%")
        XCTAssertEqual(SugarLevel.less.multiplier, 0.5, "Less should be 50%")
        XCTAssertEqual(SugarLevel.regular.multiplier, 0.7, "Regular should be 70%")
        XCTAssertEqual(SugarLevel.extra.multiplier, 1.0, "Extra should be 100%")
    }
    
    func testSugarCalculationWithBaseCalories() {
        // Test that sugar level correctly affects calorie calculations
        let baseCalories: Double = 300
        
        let noneCalories = baseCalories * SugarLevel.none.multiplier
        XCTAssertEqual(noneCalories, 0.0, "No sugar should result in 0 sugar calories")
        
        let lightCalories = baseCalories * SugarLevel.light.multiplier
        XCTAssertEqual(lightCalories, 90.0, "30% sugar should result in 90 calories")
        
        let halfCalories = baseCalories * SugarLevel.less.multiplier
        XCTAssertEqual(halfCalories, 150.0, "50% sugar should result in 150 calories")
        
        let standardCalories = baseCalories * SugarLevel.regular.multiplier
        XCTAssertEqual(standardCalories, 210.0, "70% sugar should result in 210 calories")
        
        let fullCalories = baseCalories * SugarLevel.extra.multiplier
        XCTAssertEqual(fullCalories, 300.0, "100% sugar should result in 300 calories")
    }
    
    func testSugarLevelAllCases() {
        // Verify all 5 sugar level options exist
        XCTAssertEqual(SugarLevel.allCases.count, 5, "Should have exactly 5 sugar level options")
        
        let expectedOrder: [SugarLevel] = [.none, .light, .less, .regular, .extra]
        XCTAssertEqual(SugarLevel.allCases, expectedOrder, "Sugar levels should be in ascending order")
    }
    
    func testSugarLevelLocalization() {
        // Test that localized names exist (non-empty)
        for level in SugarLevel.allCases {
            XCTAssertFalse(level.localizedName.isEmpty, "\(level) should have a localized name")
        }
    }
}

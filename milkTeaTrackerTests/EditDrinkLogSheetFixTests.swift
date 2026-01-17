//
//  EditDrinkLogSheetFixTests.swift
//  milkTeaTrackerTests
//
//  Created for testing the fixed EditDrinkLogSheet implementation
//

import XCTest
import SwiftData
@testable import mikeTeaTracker

final class EditDrinkLogSheetFixTests: XCTestCase {
    
    func testDrinkLogCanBeFetchedById() {
        // Create test logs
        let log1 = DrinkLog(
            brandId: UUID(),
            brandName: "Test 1",
            brandNameZH: "测试1",
            brandEmoji: "🍵",
            drinkName: "Drink 1",
            drinkNameZH: "饮品1",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25
        )
        
        let log2 = DrinkLog(
            brandId: UUID(),
            brandName: "Test 2",
            brandNameZH: "测试2",
            brandEmoji: "🧋",
            drinkName: "Drink 2",
            drinkNameZH: "饮品2",
            size: .large,
            sugarLevel: .less,
            iceLevel: .extra,
            calories: 400,
            sugarGrams: 30
        )
        
        let logs = [log1, log2]
        
        // Test finding by ID
        let foundLog = logs.first { $0.id == log1.id }
        XCTAssertNotNil(foundLog, "Should find log by ID")
        XCTAssertEqual(foundLog?.drinkName, "Drink 1", "Should find correct log")
        
        let foundLog2 = logs.first { $0.id == log2.id }
        XCTAssertNotNil(foundLog2, "Should find log2 by ID")
        XCTAssertEqual(foundLog2?.drinkName, "Drink 2", "Should find correct log")
    }
    
    func testDrinkLogIdIsUnique() {
        let log1 = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Test",
            drinkNameZH: "测试",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25
        )
        
        let log2 = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Test",
            drinkNameZH: "测试",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25
        )
        
        XCTAssertNotEqual(log1.id, log2.id, "Each log should have unique ID")
    }
    
    func testDrinkLogPropertiesAreAccessible() {
        let testId = UUID()
        let log = DrinkLog(
            id: testId,
            brandId: UUID(),
            brandName: "Test Brand",
            brandNameZH: "测试品牌",
            brandEmoji: "🍵",
            drinkName: "Test Drink",
            drinkNameZH: "测试饮品",
            size: .large,
            sugarLevel: .light,
            iceLevel: .none,
            calories: 250,
            sugarGrams: 18,
            price: 6.99
        )
        
        // Test all properties are accessible
        XCTAssertEqual(log.id, testId)
        XCTAssertEqual(log.brandName, "Test Brand")
        XCTAssertEqual(log.drinkName, "Test Drink")
        XCTAssertEqual(log.size, .large)
        XCTAssertEqual(log.sugarLevel, .light)
        XCTAssertEqual(log.iceLevel, .none)
        XCTAssertEqual(log.calories, 250)
        XCTAssertEqual(log.sugarGrams, 18)
        XCTAssertEqual(log.price, 6.99)
    }
    
    func testEditingLogByIdPattern() {
        // Simulate the pattern used in EditDrinkLogSheet
        var allLogs = [
            DrinkLog(
                brandId: UUID(),
                brandName: "Brand A",
                brandNameZH: "品牌A",
                brandEmoji: "🍵",
                drinkName: "Drink A",
                drinkNameZH: "饮品A",
                size: .small,
                sugarLevel: .none,
                iceLevel: .regular,
                calories: 200,
                sugarGrams: 0
            ),
            DrinkLog(
                brandId: UUID(),
                brandName: "Brand B",
                brandNameZH: "品牌B",
                brandEmoji: "🧋",
                drinkName: "Drink B",
                drinkNameZH: "饮品B",
                size: .medium,
                sugarLevel: .regular,
                iceLevel: .regular,
                calories: 300,
                sugarGrams: 25
            )
        ]
        
        // Get ID to edit
        let idToEdit = allLogs[0].id
        
        // Find and edit (simulating EditDrinkLogSheet pattern)
        if let logToEdit = allLogs.first(where: { $0.id == idToEdit }) {
            logToEdit.size = .large
            logToEdit.calories = 350
            
            XCTAssertEqual(logToEdit.size, .large, "Should update size")
            XCTAssertEqual(logToEdit.calories, 350, "Should update calories")
        } else {
            XCTFail("Should find log to edit")
        }
    }
}

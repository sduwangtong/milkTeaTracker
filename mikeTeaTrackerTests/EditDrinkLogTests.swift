//
//  EditDrinkLogTests.swift
//  mikeTeaTrackerTests
//
//  Created for testing drink log editing functionality
//

import XCTest
import SwiftData
@testable import mikeTeaTracker

final class EditDrinkLogTests: XCTestCase {
    
    func testDrinkLogCanBeModified() {
        // Create a test drink log
        let originalLog = DrinkLog(
            brandId: UUID(),
            brandName: "Test Brand",
            brandNameZH: "测试品牌",
            brandEmoji: "🍵",
            drinkName: "Test Drink",
            drinkNameZH: "测试饮品",
            size: .medium,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 300,
            sugarGrams: 25,
            price: 5.99
        )
        
        // Verify original values
        XCTAssertEqual(originalLog.size, .medium)
        XCTAssertEqual(originalLog.sugarLevel, .regular)
        XCTAssertEqual(originalLog.calories, 300)
        XCTAssertEqual(originalLog.price, 5.99)
    }
    
    func testDrinkLogSizeUpdate() {
        let log = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Test",
            drinkNameZH: "测试",
            size: .small,
            sugarLevel: .regular,
            iceLevel: .regular,
            calories: 200,
            sugarGrams: 15
        )
        
        // Change size
        log.size = .large
        XCTAssertEqual(log.size, .large, "Size should be updated to large")
    }
    
    func testDrinkLogSugarLevelUpdate() {
        let log = DrinkLog(
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
        
        // Change sugar level
        log.sugarLevel = .none
        XCTAssertEqual(log.sugarLevel, .none, "Sugar level should be updated to none")
    }
    
    func testDrinkLogCaloriesUpdate() {
        let log = DrinkLog(
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
        
        // Update calories
        log.calories = 350
        XCTAssertEqual(log.calories, 350, "Calories should be updated to 350")
    }
    
    func testDrinkLogPriceUpdate() {
        let log = DrinkLog(
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
            sugarGrams: 25,
            price: 5.99
        )
        
        // Update price
        log.price = 6.50
        XCTAssertEqual(log.price, 6.50, "Price should be updated to 6.50")
        
        // Set price to nil
        log.price = nil
        XCTAssertNil(log.price, "Price should be able to be set to nil")
    }
    
    func testDrinkLogMultipleFieldsUpdate() {
        let log = DrinkLog(
            brandId: UUID(),
            brandName: "Test",
            brandNameZH: "测试",
            brandEmoji: "🍵",
            drinkName: "Test",
            drinkNameZH: "测试",
            size: .small,
            sugarLevel: .extra,
            iceLevel: .none,
            calories: 400,
            sugarGrams: 35,
            price: 7.99
        )
        
        // Update multiple fields at once
        log.size = .large
        log.sugarLevel = .light
        log.iceLevel = .extra
        log.calories = 250
        log.sugarGrams = 18
        log.price = 8.50
        
        XCTAssertEqual(log.size, .large)
        XCTAssertEqual(log.sugarLevel, .light)
        XCTAssertEqual(log.iceLevel, .extra)
        XCTAssertEqual(log.calories, 250)
        XCTAssertEqual(log.sugarGrams, 18)
        XCTAssertEqual(log.price, 8.50)
    }
}

//
//  DrinkLog.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation
import SwiftData

@Model
final class DrinkLog {
    @Attribute(.unique) var id: UUID
    var brandId: UUID
    var brandName: String
    var brandNameZH: String
    var brandEmoji: String
    var drinkName: String
    var drinkNameZH: String
    var size: DrinkSize
    var sugarLevel: SugarLevel
    var iceLevel: IceLevel
    var bubbleLevel: BubbleLevel = BubbleLevel.none
    var calories: Double
    var sugarGrams: Double
    var price: Double?
    var timestamp: Date
    var isCustomDrink: Bool = false
    
    init(id: UUID = UUID(),
         brandId: UUID,
         brandName: String,
         brandNameZH: String,
         brandEmoji: String,
         drinkName: String,
         drinkNameZH: String,
         size: DrinkSize,
         sugarLevel: SugarLevel,
         iceLevel: IceLevel,
         bubbleLevel: BubbleLevel = .none,
         calories: Double,
         sugarGrams: Double,
         price: Double? = nil,
         timestamp: Date = Date(),
         isCustomDrink: Bool = false) {
        self.id = id
        self.brandId = brandId
        self.brandName = brandName
        self.brandNameZH = brandNameZH
        self.brandEmoji = brandEmoji
        self.drinkName = drinkName
        self.drinkNameZH = drinkNameZH
        self.size = size
        self.sugarLevel = sugarLevel
        self.iceLevel = iceLevel
        self.bubbleLevel = bubbleLevel
        self.calories = calories
        self.sugarGrams = sugarGrams
        self.price = price
        self.timestamp = timestamp
        self.isCustomDrink = isCustomDrink
    }
    
    // Helper to calculate calories and sugar from a template
    // New formula: (baseCalories * sizeMultiplier * sugarMultiplier) + bubbleCalories
    static func calculate(baseCalories: Double, baseSugar: Double, size: DrinkSize, sugarLevel: SugarLevel, bubbleLevel: BubbleLevel = .none) -> (calories: Double, sugar: Double) {
        let baseCalc = baseCalories * size.multiplier * sugarLevel.multiplier
        let calories = baseCalc + bubbleLevel.calorieAddition
        let sugar = baseSugar * size.multiplier * sugarLevel.multiplier
        return (calories, sugar)
    }
}

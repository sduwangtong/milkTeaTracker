//
//  NutritionEstimator.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation

struct NutritionEstimator {
    static func estimate(from drinkName: String) -> (calories: Double, sugar: Double) {
        let name = drinkName.lowercased()
        
        // High calorie drinks (400-500 kcal)
        if name.contains("brown sugar") || name.contains("cheese") || 
           name.contains("taro") || name.contains("chocolate") {
            return (450, 42)
        }
        
        // Medium-high (350-400 kcal)
        if name.contains("milk tea") || name.contains("latte") || 
           name.contains("thai") || name.contains("matcha") {
            return (320, 26)
        }
        
        // Medium (250-300 kcal)
        if name.contains("oolong") || name.contains("jasmine") || 
           name.contains("honeydew") {
            return (280, 23)
        }
        
        // Light drinks (150-200 kcal)
        if name.contains("tea") && !name.contains("milk") ||
           name.contains("green") || name.contains("lemon") ||
           name.contains("fruit") {
            return (180, 18)
        }
        
        // Default for unknown drinks
        return (300, 25)
    }
}

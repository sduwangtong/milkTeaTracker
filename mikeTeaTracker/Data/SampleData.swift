//
//  SampleData.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation
import SwiftData

struct SampleData {
    static let hasSeededKey = "hasSeededSampleData_v5"
    
    private static func clearOldData(context: ModelContext) {
        // Delete all existing brands, templates, and logs
        try? context.delete(model: Brand.self)
        try? context.delete(model: DrinkTemplate.self)
        try? context.save()
    }
    
    static func seedIfNeeded(context: ModelContext) {
        // Check if already seeded
        if UserDefaults.standard.bool(forKey: hasSeededKey) {
            return
        }
        
        // Clear old data first
        clearOldData(context: context)
        
        // Create brands
        let brands = createBrands(context: context)
        
        // Create drink templates for each brand
        createDrinkTemplates(for: brands, context: context)
        
        // Save
        try? context.save()
        
        // Mark as seeded
        UserDefaults.standard.set(true, forKey: hasSeededKey)
    }
    
    private static func createBrands(context: ModelContext) -> [Brand] {
        let brandsData: [(name: String, nameZH: String, emoji: String, logoName: String)] = [
            ("Kung Fu Tea", "功夫茶", "🥋", "kungfutea-logo"),
            ("Gong Cha", "贡茶", "🏆", "gongcha-logo"),
            ("Tiger Sugar", "老虎堂", "🐯", "tigersugar-logo"),
            ("It's Boba Time", "波霸时光", "⏰", "itsbobatime-logo"),
            ("CoCo Fresh Tea & Juice", "都可", "🥥", "coco-logo"),
            ("Nayuki", "奈雪的茶", "🧋", "nayuki-logo")
        ]
        
        var brands: [Brand] = []
        for data in brandsData {
            let brand = Brand(
                name: data.name,
                nameZH: data.nameZH,
                emoji: data.emoji,
                logoImageName: data.logoName,
                isPopular: true
            )
            context.insert(brand)
            brands.append(brand)
        }
        
        return brands
    }
    
    private static func createDrinkTemplates(for brands: [Brand], context: ModelContext) {
        // Kung Fu Tea drinks
        if let kungFuTea = brands.first(where: { $0.name == "Kung Fu Tea" }) {
            let drinks: [(name: String, nameZH: String, calories: Double, sugar: Double, price: Double)] = [
                ("Kung Fu Milk Tea", "功夫奶茶", 280, 23, 5.50),
                ("Taro Milk Tea", "芋头奶茶", 380, 32, 6.00),
                ("Thai Milk Tea", "泰式奶茶", 320, 27, 5.75),
                ("Matcha Milk Tea", "抹茶奶茶", 300, 24, 5.95),
                ("Honeydew Milk Tea", "蜜瓜奶茶", 340, 29, 5.95),
                ("Brown Sugar Milk Tea", "黑糖奶茶", 420, 42, 6.25),
                ("Oolong Milk Tea", "乌龙奶茶", 275, 22, 5.50),
                ("Passion Fruit Green Tea", "百香果绿茶", 180, 18, 5.25),
                ("Mango Green Tea", "芒果绿茶", 200, 20, 5.50),
                ("Lychee Black Tea", "荔枝红茶", 190, 19, 5.25)
            ]
            createTemplates(drinks: drinks, brand: kungFuTea, context: context)
        }
        
        // Gong Cha drinks
        if let gongCha = brands.first(where: { $0.name == "Gong Cha" }) {
            let drinks: [(name: String, nameZH: String, calories: Double, sugar: Double, price: Double)] = [
                ("Black Milk Tea", "红茶拿铁", 290, 24, 7.50),
                ("Oolong Milk Tea", "乌龙奶茶", 280, 23, 7.50),
                ("Brown Sugar Milk Tea", "黑糖奶茶", 410, 40, 7.90),
                ("Taro Milk Tea", "芋头奶茶", 370, 31, 7.75),
                ("Matcha Milk Tea", "抹茶奶茶", 310, 25, 7.75),
                ("Strawberry Milk Tea", "草莓奶茶", 330, 28, 7.85),
                ("Milk Foam Green Tea", "奶盖绿茶", 305, 26, 8.00),
                ("Wintermelon Tea", "冬瓜茶", 220, 22, 7.25),
                ("Passion Fruit Yogurt Slush", "百香果优格冰沙", 190, 20, 7.95),
                ("Peach Oolong Tea", "水蜜桃乌龙", 160, 16, 7.50)
            ]
            createTemplates(drinks: drinks, brand: gongCha, context: context)
        }
        
        // Tiger Sugar drinks
        if let tigerSugar = brands.first(where: { $0.name == "Tiger Sugar" }) {
            let drinks: [(name: String, nameZH: String, calories: Double, sugar: Double, price: Double)] = [
                ("Brown Sugar Boba Milk", "黑糖波霸鲜奶", 450, 54, 7.99),
                ("Brown Sugar Pearl Latte", "黑糖珍珠拿铁", 420, 48, 7.99),
                ("Brown Sugar with Cream Mousse", "黑糖奶盖", 480, 52, 8.25),
                ("Brown Sugar Cheese Brulee", "黑糖芝士布蕾", 490, 56, 8.50),
                ("Black Sugar Boba Milk", "黑糖波霸", 440, 50, 7.99),
                ("Green Tea Brown Sugar Boba", "绿茶黑糖波霸", 410, 46, 8.15),
                ("Strawberry Brown Sugar Milk", "草莓黑糖鲜奶", 460, 54, 8.25),
                ("Taro Brown Sugar Milk", "芋头黑糖鲜奶", 470, 55, 8.25),
                ("Matcha Brown Sugar Latte", "抹茶黑糖拿铁", 430, 49, 8.15),
                ("Cocoa Brown Sugar Milk", "可可黑糖鲜奶", 500, 58, 8.35)
            ]
            createTemplates(drinks: drinks, brand: tigerSugar, context: context)
        }
        
        // It's Boba Time drinks
        if let bobaTime = brands.first(where: { $0.name == "It's Boba Time" }) {
            let drinks: [(name: String, nameZH: String, calories: Double, sugar: Double, price: Double)] = [
                ("Thai Milk Tea", "泰式奶茶", 340, 29, 6.25),
                ("Taro Milk Tea", "芋头奶茶", 390, 33, 6.50),
                ("Brown Sugar Milk Tea", "黑糖奶茶", 430, 43, 6.75),
                ("Strawberry Milk Tea", "草莓奶茶", 360, 30, 6.50),
                ("Matcha Milk Tea", "抹茶奶茶", 320, 26, 6.25),
                ("Classic Milk Tea", "经典奶茶", 295, 24, 5.75),
                ("Honeydew Milk Tea", "蜜瓜奶茶", 350, 30, 6.25),
                ("Mango Milk Tea", "芒果奶茶", 330, 28, 6.50),
                ("Almond Milk Tea", "杏仁奶茶", 310, 25, 6.00),
                ("Jasmine Green Tea", "茉莉绿茶", 170, 17, 5.50)
            ]
            createTemplates(drinks: drinks, brand: bobaTime, context: context)
        }
        
        // CoCo Fresh Tea & Juice drinks
        if let coco = brands.first(where: { $0.name == "CoCo Fresh Tea & Juice" }) {
            let drinks: [(name: String, nameZH: String, calories: Double, sugar: Double, price: Double)] = [
                ("Bubble Milk Tea", "珍珠奶茶", 388, 28, 7.26),
                ("3 Guys Milk Tea", "三兄弟", 450, 32, 7.95),
                ("Taro Milk Tea", "芋头奶茶", 400, 30, 7.50),
                ("Brown Sugar Boba Latte", "黑糖珍珠拿铁", 420, 35, 7.75),
                ("Mango Green Tea", "芒果绿茶", 200, 20, 7.03),
                ("Bubble Gaga", "百香双响炮", 220, 22, 7.50),
                ("Lava Pearl Matcha Latte", "火山珍珠抹茶拿铁", 380, 28, 7.90),
                ("Black Tea with Cloud", "黑茶奶盖", 300, 24, 7.25),
                ("Mango Yakult", "芒果养乐多", 210, 21, 7.72),
                ("2 Ladies", "双拼奶茶", 438, 30, 7.49)
            ]
            createTemplates(drinks: drinks, brand: coco, context: context)
        }
        
        // Nayuki drinks
        if let nayuki = brands.first(where: { $0.name == "Nayuki" }) {
            let drinks: [(name: String, nameZH: String, calories: Double, sugar: Double, price: Double)] = [
                ("Strawberry Cheese", "霸气芝士草莓", 450, 35, 8.50),
                ("Grape Cheese", "霸气芝士葡萄", 420, 32, 8.25),
                ("Mango Cheese", "霸气芝士芒果", 440, 34, 8.50),
                ("Peach Oolong", "霸气桃桃", 380, 30, 7.75),
                ("Bawang Yuganzi", "霸气玉油柑", 280, 24, 7.50),
                ("Jasmine Green Tea", "茉莉绿茶", 180, 15, 7.00),
                ("Oolong Milk Tea", "乌龙奶茶", 320, 26, 7.50),
                ("Brown Sugar Boba Milk", "黑糖波霸", 410, 40, 8.00),
                ("Lemon Tea", "柠檬茶", 160, 14, 7.00),
                ("Taro Milk Tea", "芋泥波波", 390, 32, 8.25)
            ]
            createTemplates(drinks: drinks, brand: nayuki, context: context)
        }
    }
    
    private static func createTemplates(drinks: [(name: String, nameZH: String, calories: Double, sugar: Double, price: Double)], brand: Brand, context: ModelContext) {
        for drink in drinks {
            let template = DrinkTemplate(
                name: drink.name,
                nameZH: drink.nameZH,
                baseCalories: drink.calories,
                baseSugar: drink.sugar,
                basePrice: drink.price,
                brand: brand
            )
            context.insert(template)
        }
    }
}

//
//  DrinkTemplate.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation
import SwiftData

@Model
final class DrinkTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var nameZH: String
    var baseCalories: Double
    var baseSugar: Double // in grams
    var basePrice: Double? // Price in USD for medium size
    
    @Relationship var brand: Brand?
    
    init(id: UUID = UUID(), name: String, nameZH: String, baseCalories: Double, baseSugar: Double, basePrice: Double? = nil, brand: Brand? = nil) {
        self.id = id
        self.name = name
        self.nameZH = nameZH
        self.baseCalories = baseCalories
        self.baseSugar = baseSugar
        self.basePrice = basePrice
        self.brand = brand
    }
}

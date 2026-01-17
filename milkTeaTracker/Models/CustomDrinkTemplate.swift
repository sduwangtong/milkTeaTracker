//
//  CustomDrinkTemplate.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation
import SwiftData

@Model
final class CustomDrinkTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var nameZH: String
    var customCalories: Double
    var customSugar: Double
    var price: Double? // Price in USD
    var isCustom: Bool = true
    var createdDate: Date
    
    // Custom drinks don't have a brand relationship
    
    init(id: UUID = UUID(), 
         name: String,
         nameZH: String = "",
         customCalories: Double,
         customSugar: Double,
         price: Double? = nil) {
        self.id = id
        self.name = name
        self.nameZH = nameZH.isEmpty ? name : nameZH
        self.customCalories = customCalories
        self.customSugar = customSugar
        self.price = price
        self.createdDate = Date()
    }
}

//
//  Brand.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation
import SwiftData

@Model
final class Brand {
    @Attribute(.unique) var id: UUID
    var name: String
    var nameZH: String
    var emoji: String // Keep as fallback
    var logoImageName: String? // Asset Catalog image name
    var isPopular: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \DrinkTemplate.brand)
    var drinkTemplates: [DrinkTemplate]?
    
    init(id: UUID = UUID(), name: String, nameZH: String, emoji: String, logoImageName: String? = nil, isPopular: Bool = false) {
        self.id = id
        self.name = name
        self.nameZH = nameZH
        self.emoji = emoji
        self.logoImageName = logoImageName
        self.isPopular = isPopular
    }
}

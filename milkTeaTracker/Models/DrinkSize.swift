//
//  DrinkSize.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation

enum DrinkSize: String, Codable, CaseIterable {
    case small
    case medium
    case large
    
    var multiplier: Double {
        switch self {
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.3
        }
    }
    
    var localizedName: String {
        switch self {
        case .small: return String(localized: "size_small")
        case .medium: return String(localized: "size_medium")
        case .large: return String(localized: "size_large")
        }
    }
}

enum SugarLevel: String, Codable, CaseIterable {
    case none
    case light
    case less
    case regular
    case extra
    
    var multiplier: Double {
        switch self {
        case .none: return 0.0
        case .light: return 0.3
        case .less: return 0.5
        case .regular: return 0.7
        case .extra: return 1.0
        }
    }
    
    var localizedName: String {
        switch self {
        case .none: return String(localized: "sugar_none")
        case .light: return String(localized: "sugar_light")
        case .less: return String(localized: "sugar_less")
        case .regular: return String(localized: "sugar_regular")
        case .extra: return String(localized: "sugar_extra")
        }
    }
}

enum IceLevel: String, Codable, CaseIterable {
    case none
    case less
    case regular
    case extra
    
    var localizedName: String {
        switch self {
        case .none: return String(localized: "ice_none")
        case .less: return String(localized: "ice_less")
        case .regular: return String(localized: "ice_regular")
        case .extra: return String(localized: "ice_extra")
        }
    }
}

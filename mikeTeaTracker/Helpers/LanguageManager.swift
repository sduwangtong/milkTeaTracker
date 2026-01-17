//
//  LanguageManager.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation
import SwiftUI

@Observable
class LanguageManager {
    static let shared = LanguageManager()
    
    var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "app_language")
        }
    }
    
    var locale: Locale {
        Locale(identifier: currentLanguage)
    }
    
    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: "app_language") ?? "en"
    }
    
    func toggleLanguage() {
        currentLanguage = (currentLanguage == "en") ? "zh-Hans" : "en"
    }
    
    var isEnglish: Bool {
        currentLanguage == "en"
    }
    
    var isChinese: Bool {
        currentLanguage == "zh-Hans"
    }
}

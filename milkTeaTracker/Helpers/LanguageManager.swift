//
//  LanguageManager.swift
//  milkTeaTracker
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
            // Set AppleLanguages to force the app bundle to use this language
            // This makes String(localized:) respect our language choice on next launch
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    var locale: Locale {
        Locale(identifier: currentLanguage)
    }
    
    /// Returns the bundle for the current language to load localized strings at runtime
    /// This allows immediate language switching without app restart
    private var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
    
    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.currentLanguage = savedLanguage
        // Ensure AppleLanguages is set on init for proper localization
        UserDefaults.standard.set([savedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func toggleLanguage() {
        currentLanguage = (currentLanguage == "en") ? "zh-Hans" : "en"
    }
    
    /// Get a localized string from the current language bundle
    /// Use this for immediate language switching (e.g., navigation titles, alerts)
    /// SwiftUI Text views with LocalizedStringKey will update automatically via .id() modifier
    func localizedString(_ key: String) -> String {
        return bundle.localizedString(forKey: key, value: nil, table: "Localizable")
    }
    
    /// Get a localized string with format arguments
    /// Use this for strings that contain format specifiers like %d, %lld, %@
    /// Example: localizedString("free_scans_format", args: remaining, total)
    func localizedString(_ key: String, args: CVarArg...) -> String {
        let format = bundle.localizedString(forKey: key, value: nil, table: "Localizable")
        return String(format: format, arguments: args)
    }
    
    var isEnglish: Bool {
        currentLanguage == "en"
    }
    
    var isChinese: Bool {
        currentLanguage == "zh-Hans"
    }
}

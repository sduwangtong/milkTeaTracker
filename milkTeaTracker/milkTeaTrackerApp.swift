//
//  milkTeaTrackerApp.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

@main
struct milkTeaTrackerApp: App {
    @State private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(languageManager)
        }
        .modelContainer(for: [Brand.self, DrinkTemplate.self, DrinkLog.self, CustomDrinkTemplate.self, UserGoals.self])
    }
}

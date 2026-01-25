//
//  UserGoals.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import Foundation
import SwiftData

@Model
final class UserGoals {
    @Attribute(.unique) var id: UUID
    
    // Simple weekly cup goal - one number, no choices
    var weeklyCupGoal: Int?
    
    // Legacy properties for migration (kept for SwiftData schema compatibility)
    var cupGoal: Int?
    var goalFrequencyRaw: String?
    var monthlyCupGoal: Int?
    var monthlyCalorieGoal: Double?
    var weeklyCalorieGoal: Double?
    
    var createdDate: Date
    var lastUpdated: Date
    var hasMigrated: Bool = false
    
    init(id: UUID = UUID(), weeklyCupGoal: Int? = nil) {
        self.id = id
        self.weeklyCupGoal = weeklyCupGoal
        self.createdDate = Date()
        self.lastUpdated = Date()
        self.hasMigrated = true
    }
    
    /// Migrate from old models to simple weekly goal
    func migrateIfNeeded() {
        guard !hasMigrated else { return }
        
        // Migration priority:
        // 1. Use existing weeklyCupGoal if set
        // 2. Use cupGoal if it was set (from previous migration)
        // 3. Convert monthlyCupGoal to weekly (divide by 4)
        if weeklyCupGoal == nil {
            if let cup = cupGoal {
                weeklyCupGoal = cup
            } else if let monthly = monthlyCupGoal {
                weeklyCupGoal = monthly / 4
            }
        }
        
        // Clear all legacy values
        cupGoal = nil
        goalFrequencyRaw = nil
        monthlyCupGoal = nil
        monthlyCalorieGoal = nil
        weeklyCalorieGoal = nil
        
        hasMigrated = true
        lastUpdated = Date()
    }
}

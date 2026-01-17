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
    var monthlyCupGoal: Int?
    var monthlyCalorieGoal: Double?
    var weeklyCupGoal: Int?
    var weeklyCalorieGoal: Double?
    var createdDate: Date
    var lastUpdated: Date
    
    init(id: UUID = UUID(),
         monthlyCupGoal: Int? = nil,
         monthlyCalorieGoal: Double? = nil,
         weeklyCupGoal: Int? = nil,
         weeklyCalorieGoal: Double? = nil) {
        self.id = id
        self.monthlyCupGoal = monthlyCupGoal
        self.monthlyCalorieGoal = monthlyCalorieGoal
        self.weeklyCupGoal = weeklyCupGoal
        self.weeklyCalorieGoal = weeklyCalorieGoal
        self.createdDate = Date()
        self.lastUpdated = Date()
    }
}

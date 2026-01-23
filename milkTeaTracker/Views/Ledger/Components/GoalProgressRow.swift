//
//  GoalProgressRow.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct GoalProgressRow: View {
    let title: String
    let current: Int
    let goal: Int?
    let unit: String
    let color: Color
    @Binding var isEditing: Bool
    let onSave: (Int) -> Void
    
    private var progress: Double {
        guard let goal = goal, goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }
    
    private var remaining: Int {
        guard let goal = goal else { return 0 }
        return max(goal - current, 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 16))
                
                Spacer()
                
                if let goal = goal {
                    Button(action: { isEditing = true }) {
                        Text("\(current)/\(goal) \(unit)")
                            .font(.system(size: 16))
                            .foregroundStyle(.primary)
                    }
                } else {
                    Button(action: { isEditing = true }) {
                        Text(String(localized: "set_goal"))
                            .font(.system(size: 16))
                            .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                    }
                }
            }
            
            ProgressView(value: progress)
                .tint(color)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            if let goal = goal, remaining > 0 {
            if unit == "cups" {
                Text(String(format: String(localized: "can_still_drink"), remaining))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            } else {
                Text(String(format: String(localized: "can_still_consume"), remaining))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            }
        }
        .sheet(isPresented: $isEditing) {
            GoalEditSheet(
                currentValue: goal,
                unit: unit,
                onSave: onSave
            )
        }
    }
}

//
//  RecentDrinkRow.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct RecentDrinkRow: View {
    let drinkLog: DrinkLog
    let onQuickLog: () -> Void
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Left: Emoji icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.93, green: 0.26, blue: 0.55).opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Text(drinkLog.brandEmoji)
                    .font(.system(size: 28))
            }
            
            // Center: Drink info
            VStack(alignment: .leading, spacing: 4) {
                Text(languageManager.isEnglish ? drinkLog.drinkName : drinkLog.drinkNameZH)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Text(languageManager.isEnglish ? drinkLog.brandName : drinkLog.brandNameZH)
                    Text("·")
                    Text(drinkLog.size.localizedName(using: languageManager))
                    Text("·")
                    Text(drinkLog.sugarLevel.localizedName(using: languageManager))
                }
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Right: Calories and quick log button
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(drinkLog.calories))\(languageManager.localizedString("kcal_unit"))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                
                Button(action: onQuickLog) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let log = DrinkLog(
        brandId: UUID(),
        brandName: "HeyTea",
        brandNameZH: "喜茶",
        brandEmoji: "🍵",
        drinkName: "Grape Cheese Tea",
        drinkNameZH: "芝芝葡萄",
        size: .medium,
        sugarLevel: .less,
        iceLevel: .regular,
        calories: 320,
        sugarGrams: 25
    )
    
    return RecentDrinkRow(drinkLog: log, onQuickLog: {})
        .padding()
        .environment(LanguageManager.shared)
}

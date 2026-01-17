//
//  DailyLogRow.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct DailyLogRow: View {
    let log: DrinkLog
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
        HStack(spacing: 12) {
            Text(log.brandEmoji)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(languageManager.isEnglish ? log.drinkName : log.drinkNameZH)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 6) {
                    Text(log.size.localizedName)
                    Text("•")
                    Text(log.sugarLevel.localizedName)
                    if let price = log.price {
                        Text("•")
                        Text("$\(String(format: "%.2f", price))")
                    }
                }
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(log.calories)) kcal")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
        }
        .padding(.vertical, 8)
    }
}

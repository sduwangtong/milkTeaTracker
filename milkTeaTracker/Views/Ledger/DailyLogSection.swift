//
//  DailyLogSection.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct DailyLogSection: View {
    let logs: [DrinkLog]
    @Environment(LanguageManager.self) private var languageManager
    
    private var groupedLogs: [(Date, [DrinkLog])] {
        logs.groupedByDate()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(String(localized: "daily_log"))
                    .font(.system(size: 18, weight: .semibold))
            }
            
            if groupedLogs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text(String(localized: "no_drinks_logged"))
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(groupedLogs, id: \.0) { date, dayLogs in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(date, style: .date)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(dayLogs.enumerated()), id: \.element.id) { index, log in
                                DailyLogRow(log: log)
                                
                                if index < dayLogs.count - 1 {
                                    Divider()
                                        .padding(.leading, 56)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
                    }
                }
            }
        }
    }
}

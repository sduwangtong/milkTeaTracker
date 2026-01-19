//
//  AllDrinksListView.swift
//  milkTeaTracker
//
//  Created for viewing all logged drinks
//

import SwiftUI
import SwiftData

struct AllDrinksListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    @State private var toastManager = ToastManager()
    
    @Query(sort: \DrinkLog.timestamp, order: .reverse) private var allDrinkLogs: [DrinkLog]
    
    @State private var selectedDrinkLog: DrinkLog?
    
    // Group logs by date
    private var groupedLogs: [(date: Date, logs: [DrinkLog])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allDrinkLogs) { log in
            calendar.startOfDay(for: log.timestamp)
        }
        return grouped.sorted { $0.key > $1.key }.map { (date: $0.key, logs: $0.value) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if allDrinkLogs.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "no_drinks_logged"))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "start_logging_drinks"))
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    // List of all drinks grouped by date
                    List {
                        ForEach(groupedLogs, id: \.date) { group in
                            Section {
                                ForEach(group.logs, id: \.id) { log in
                                    RecentDrinkRow(drinkLog: log) {
                                        quickReLog(log)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteDrinkLog(log)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            selectedDrinkLog = log
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                }
                            } header: {
                                Text(formatDate(group.date))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .textCase(nil)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(String(localized: "all_drinks"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "done")) {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedDrinkLog) { log in
                EditDrinkLogSheet(drinkLog: log, toastManager: toastManager, onSave: {
                    selectedDrinkLog = nil
                })
            }
        }
        .toast(toastManager)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return String(localized: "today")
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "yesterday")
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    private func quickReLog(_ existingLog: DrinkLog) {
        let newLog = DrinkLog(
            brandId: existingLog.brandId,
            brandName: existingLog.brandName,
            brandNameZH: existingLog.brandNameZH,
            brandEmoji: existingLog.brandEmoji,
            drinkName: existingLog.drinkName,
            drinkNameZH: existingLog.drinkNameZH,
            size: existingLog.size,
            sugarLevel: existingLog.sugarLevel,
            iceLevel: existingLog.iceLevel,
            calories: existingLog.calories,
            sugarGrams: existingLog.sugarGrams,
            price: existingLog.price,
            timestamp: Date()
        )
        
        modelContext.insert(newLog)
        try? modelContext.save()
        
        toastManager.show(String(localized: "logged_toast"))
    }
    
    private func deleteDrinkLog(_ log: DrinkLog) {
        modelContext.delete(log)
        try? modelContext.save()
    }
}

#Preview {
    AllDrinksListView()
        .modelContainer(for: [DrinkLog.self])
        .environment(LanguageManager.shared)
}

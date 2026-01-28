//
//  DrinkSelectionView.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct DrinkSelectionView: View {
    let brand: Brand
    let toastManager: ToastManager
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    
    @Query(sort: \DrinkTemplate.name) private var allDrinkTemplates: [DrinkTemplate]
    @State private var searchText = ""
    @State private var selectedDrink: DrinkTemplate?
    
    // Filter drinks for this brand manually
    private var drinkTemplates: [DrinkTemplate] {
        allDrinkTemplates.filter { drink in
            drink.brand?.id == brand.id
        }
    }
    
    private var filteredDrinks: [DrinkTemplate] {
        if searchText.isEmpty {
            return drinkTemplates
        }
        return drinkTemplates.filter { drink in
            drink.name.localizedCaseInsensitiveContains(searchText) ||
            drink.nameZH.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField(String(localized: "search_placeholder"), text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(12)
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
                // Drinks List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredDrinks, id: \.id) { drink in
                            DrinkTemplateRow(drink: drink, brandEmoji: brand.emoji) {
                                selectedDrink = drink
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            
                            if drink.id != filteredDrinks.last?.id {
                                Divider()
                                    .padding(.leading, 80)
                            }
                        }
                    }
                }
            }
            .navigationTitle("\(brand.emoji) \(languageManager.isEnglish ? brand.name : brand.nameZH)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "done_button")) {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedDrink) { drink in
                DrinkOptionsSheet(
                    brandId: brand.id,
                    drinkTemplateId: drink.id,
                    toastManager: toastManager,
                    onSave: {
                        selectedDrink = nil
                        dismiss()
                    }
                )
            }
        }
    }
}

struct DrinkTemplateRow: View {
    let drink: DrinkTemplate
    let brandEmoji: String
    let onTap: () -> Void
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Emoji
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.93, green: 0.26, blue: 0.55).opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Text(brandEmoji)
                        .font(.system(size: 28))
                }
                
                // Drink info
                VStack(alignment: .leading, spacing: 4) {
                    Text(languageManager.isEnglish ? drink.name : drink.nameZH)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text("\(String(localized: "calories_label")): ~\(Int(drink.baseCalories))\(String(localized: "kcal_unit"))")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    do {
        let container = try ModelContainer(for: Brand.self, DrinkTemplate.self, DrinkLog.self, configurations: config)
        let brand = Brand(name: "HeyTea", nameZH: "喜茶", emoji: "🍵", isPopular: true)
        container.mainContext.insert(brand)
        
        return DrinkSelectionView(brand: brand, toastManager: ToastManager())
            .modelContainer(container)
            .environment(LanguageManager.shared)
    } catch {
        return Text("Preview Error: \(error.localizedDescription)")
            .environment(LanguageManager.shared)
    }
}

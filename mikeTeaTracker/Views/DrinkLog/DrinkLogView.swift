//
//  DrinkLogView.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct DrinkLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    @State private var toastManager = ToastManager()
    
    @Query(sort: \Brand.name) private var allBrands: [Brand]
    @Query(sort: \DrinkLog.timestamp, order: .reverse) private var allDrinkLogs: [DrinkLog]
    
    @State private var searchText = ""
    @State private var selectedBrandId: UUID?
    @State private var showingDrinkSelection = false
    @State private var showingCustomDrinkEntry = false
    @State private var showingEditDrink = false
    @State private var selectedDrinkLog: DrinkLog?
    @State private var showingAllDrinks = false
    
    private var popularBrands: [Brand] {
        allBrands.filter { $0.isPopular }
    }
    
    private var recentDrinks: [DrinkLog] {
        Array(allDrinkLogs.prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Subtitle
                    Text(String(localized: "log_subtitle"))
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
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
                    .padding(.horizontal)
                    
                    // Quick Log Button (moved to top)
                    Button(action: {
                        showingCustomDrinkEntry = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                            Text(String(localized: "custom_drink_button"))
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0.93, green: 0.26, blue: 0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                    
                    // Popular Brands Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "popular_brands"))
                            .font(.system(size: 17, weight: .semibold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(popularBrands, id: \.id) { brand in
                                BrandCard(brand: brand) {
                                    selectedBrandId = brand.id
                                    showingDrinkSelection = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Drinks Section
                    if !recentDrinks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(String(localized: "recent_drinks"))
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Spacer()
                                
                                Button(String(localized: "view_all")) {
                                    showingAllDrinks = true
                                }
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(recentDrinks, id: \.id) { log in
                                    RecentDrinkRow(drinkLog: log) {
                                        quickReLog(log)
                                    }
                                    .padding(.horizontal)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteDrinkLog(log)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            selectedDrinkLog = log
                                            showingEditDrink = true
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                    
                                    if log.id != recentDrinks.last?.id {
                                        Divider()
                                            .padding(.leading, 80)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle(String(localized: "drink_log"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        languageManager.toggleLanguage()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                            Text(languageManager.isEnglish ? "EN" : "中")
                        }
                        .font(.system(size: 14, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $showingDrinkSelection) {
                if let brandId = selectedBrandId {
                    DrinkSelectionView(brandId: brandId, toastManager: toastManager)
                }
            }
            .sheet(isPresented: $showingCustomDrinkEntry) {
                CustomDrinkEntrySheet(toastManager: toastManager, onSave: {})
            }
            .sheet(isPresented: $showingEditDrink) {
                if let log = selectedDrinkLog {
                    EditDrinkLogSheet(drinkLogId: log.id, toastManager: toastManager, onSave: {
                        showingEditDrink = false
                        selectedDrinkLog = nil
                    })
                }
            }
            .sheet(isPresented: $showingAllDrinks) {
                AllDrinksListView()
            }
        }
        .toast(toastManager)
        .onAppear {
            // Seed sample data if needed
            SampleData.seedIfNeeded(context: modelContext)
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
    DrinkLogView()
        .modelContainer(for: [Brand.self, DrinkTemplate.self, DrinkLog.self])
        .environment(LanguageManager.shared)
}

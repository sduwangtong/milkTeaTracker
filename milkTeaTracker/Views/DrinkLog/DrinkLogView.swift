//
//  DrinkLogView.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct DrinkLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    @Environment(AuthManager.self) private var authManager
    @Environment(FreeUsageManager.self) private var freeUsageManager
    @State private var toastManager = ToastManager()
    
    @Query(sort: \Brand.name) private var allBrands: [Brand]
    @Query(sort: \DrinkLog.timestamp, order: .reverse) private var allDrinkLogs: [DrinkLog]
    
    @State private var searchText = ""
    @State private var selectedBrand: Brand?
    @State private var showingCustomDrinkEntry = false
    @State private var selectedDrinkLog: DrinkLog?
    @State private var showingAllDrinks = false
    
    // Snap camera state
    @State private var showingSnapCamera = false
    @State private var parsedReceipt: ParsedReceipt?
    @State private var isProcessingSnap = false
    
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
                    Text(languageManager.localizedString("log_subtitle"))
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Free scans remaining indicator
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text(languageManager.localizedString("free_scans_format", args: freeUsageManager.remainingScans, freeUsageManager.weeklyLimit))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(freeUsageManager.canScan ? Color(red: 0.2, green: 0.6, blue: 0.86) : .red)
                    .padding(.horizontal)
                    
                    // Search Bar (hidden with popular brands)
                    if FeatureFlags.showPopularBrands {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            
                            TextField(languageManager.localizedString("search_placeholder"), text: $searchText)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    }
                    
                    // Quick Log and Snap Buttons
                    HStack(spacing: 12) {
                        // Quick Log Button
                        Button(action: {
                            showingCustomDrinkEntry = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                Text(languageManager.localizedString("custom_drink_button"))
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(red: 0.93, green: 0.26, blue: 0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .accessibilityLabel(languageManager.localizedString("custom_drink_button"))
                        .accessibilityHint(languageManager.localizedString("custom_drink_hint"))
                        
                        // Snap Button - direct camera access (disabled when no free scans left)
                        Button(action: {
                            showingSnapCamera = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                Text(languageManager.localizedString("snap_button"))
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(freeUsageManager.canScan ? .white : .gray)
                            .frame(width: 70)
                            .padding(.vertical, 12)
                            .background(freeUsageManager.canScan ? Color(red: 0.2, green: 0.6, blue: 0.86) : Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!freeUsageManager.canScan || isProcessingSnap)
                        .accessibilityLabel(languageManager.localizedString("snap_button"))
                        .accessibilityHint(freeUsageManager.canScan ? languageManager.localizedString("snap_hint") : languageManager.localizedString("snap_disabled_hint"))
                    }
                    .padding(.horizontal)
                    
                    // Banner Ad (between Quick Log and content)
                    if FeatureFlags.showBannerAdsInMainViews && AdManager.shared.shouldShowAds() {
                        BannerAdView()
                            .padding(.horizontal)
                    }
                    
                    // Popular Brands Section
                    if FeatureFlags.showPopularBrands {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(languageManager.localizedString("popular_brands"))
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(popularBrands, id: \.id) { brand in
                                    BrandCard(brand: brand) {
                                        selectedBrand = brand
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Drinks Section
                    if !recentDrinks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(languageManager.localizedString("recent_drinks"))
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Spacer()
                                
                                Button(languageManager.localizedString("view_all")) {
                                    showingAllDrinks = true
                                }
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                            }
                            .padding(.horizontal)
                            
                            List {
                                ForEach(recentDrinks, id: \.id) { log in
                                    RecentDrinkRow(drinkLog: log) {
                                        quickReLog(log)
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteDrinkLog(log)
                                        } label: {
                                            Label(languageManager.localizedString("delete"), systemImage: "trash")
                                        }
                                        
                                        Button {
                                            selectedDrinkLog = log
                                        } label: {
                                            Label(languageManager.localizedString("edit"), systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .frame(height: CGFloat(recentDrinks.count) * 72)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle(languageManager.localizedString("drink_log"))
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
            .sheet(item: $selectedBrand) { brand in
                DrinkSelectionView(brand: brand, toastManager: toastManager)
            }
            .sheet(isPresented: $showingCustomDrinkEntry) {
                CustomDrinkEntrySheet(
                    toastManager: toastManager,
                    onSave: {
                        // Clear parsed receipt after saving
                        parsedReceipt = nil
                    },
                    initialReceipt: parsedReceipt
                )
            }
            .sheet(item: $selectedDrinkLog) { log in
                EditDrinkLogSheet(drinkLog: log, toastManager: toastManager, onSave: {
                    selectedDrinkLog = nil
                })
            }
            .sheet(isPresented: $showingAllDrinks) {
                AllDrinksListView()
            }
            .sheet(isPresented: $showingSnapCamera) {
                ReceiptScannerView(parsedReceipt: $parsedReceipt, isProcessing: $isProcessingSnap)
            }
            .overlay {
                // AI Processing overlay for Snap feature
                if isProcessingSnap {
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ZStack {
                                // Camera icon
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white)
                                
                                // Sparkles around camera
                                Image(systemName: "sparkles")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.yellow)
                                    .offset(x: 30, y: -25)
                            }
                            
                            Text(languageManager.localizedString("snap_processing"))
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.2)
                        }
                        .padding(40)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: isProcessingSnap)
                }
            }
        }
        .toast(toastManager)
        .onAppear {
            // Seed sample data if needed
            SampleData.seedIfNeeded(context: modelContext)
        }
        .onChange(of: parsedReceipt) { _, newValue in
            // When snap camera returns a parsed receipt, open custom drink entry with data
            if newValue != nil {
                showingCustomDrinkEntry = true
            }
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
        
        // Log to Google Sheets with location (fire-and-forget)
        if let user = authManager.currentUser,
           let email = user.email {
            Task {
                let location = await LocationManager.shared.getLocationForLogging()
                await DrinkLoggerService.shared.logDrink(
                    email: email,
                    name: user.displayName ?? "Unknown",
                    drink: newLog,
                    location: location
                )
            }
        }
        
        toastManager.show(languageManager.localizedString("logged_toast"))
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
        .environment(FreeUsageManager.shared)
}

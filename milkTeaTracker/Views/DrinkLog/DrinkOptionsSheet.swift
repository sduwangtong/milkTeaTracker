//
//  DrinkOptionsSheet.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct DrinkOptionsSheet: View {
    let brandId: UUID
    let drinkTemplateId: UUID
    let toastManager: ToastManager
    let onSave: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    @Environment(AuthManager.self) private var authManager
    
    @Query private var allBrands: [Brand]
    @Query private var allDrinkTemplates: [DrinkTemplate]
    
    @State private var selectedSize: DrinkSize = .medium
    @State private var selectedSugar: SugarLevel = .regular
    @State private var selectedIce: IceLevel = .regular
    @State private var priceText: String = ""
    @FocusState private var isPriceFocused: Bool
    
    // Re-fetch objects from context to avoid detached model issues
    private var brand: Brand? {
        allBrands.first { $0.id == brandId }
    }
    
    private var drinkTemplate: DrinkTemplate? {
        allDrinkTemplates.first { $0.id == drinkTemplateId }
    }
    
    private var calculatedCalories: Double {
        guard let template = drinkTemplate else { return 0 }
        return template.baseCalories * selectedSize.multiplier * selectedSugar.multiplier
    }
    
    private var calculatedSugar: Double {
        guard let template = drinkTemplate else { return 0 }
        return template.baseSugar * selectedSize.multiplier * selectedSugar.multiplier
    }
    
    var body: some View {
        NavigationStack {
            if let brand = brand, let template = drinkTemplate {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Drink Header
                        HStack(spacing: 12) {
                            Text(brand.emoji)
                                .font(.system(size: 48))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(languageManager.isEnglish ? template.name : template.nameZH)
                                    .font(.system(size: 20, weight: .bold))
                                
                                Text(languageManager.isEnglish ? brand.name : brand.nameZH)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Size Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "size_label"))
                            .font(.system(size: 16, weight: .semibold))
                        
                        Picker("", selection: $selectedSize) {
                            ForEach(DrinkSize.allCases, id: \.self) { size in
                                Text(size.localizedName).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Sugar Level Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "sugar_label"))
                            .font(.system(size: 16, weight: .semibold))
                        
                        Picker("", selection: $selectedSugar) {
                            ForEach(SugarLevel.allCases, id: \.self) { sugar in
                                Text(sugar.localizedName).tag(sugar)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Ice Level Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "ice_label"))
                            .font(.system(size: 16, weight: .semibold))
                        
                        Picker("", selection: $selectedIce) {
                            ForEach(IceLevel.allCases, id: \.self) { ice in
                                Text(ice.localizedName).tag(ice)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Price Input (Optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "price_label"))
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextField("0.00", text: $priceText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($isPriceFocused)
                    }
                    
                    // Nutrition Preview
                    VStack(spacing: 16) {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "calories_label"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("\(Int(calculatedCalories))")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                                    
                                    Text(String(localized: "kcal_unit"))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(localized: "sugar_grams_label"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(String(format: "%.1f", calculatedSugar))
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                                    
                                    Text(String(localized: "grams_unit"))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                        // Log Button
                        Button(action: logDrink) {
                            Text(String(localized: "log_drink_button"))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.93, green: 0.26, blue: 0.55))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
                .navigationTitle(String(localized: "select_drink"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isPriceFocused = false
                        }
                    }
                }
                .onAppear {
                    // Pre-fill price from drink template
                    if let basePrice = template.basePrice {
                        priceText = String(format: "%.2f", basePrice)
                    }
                }
            } else {
                ProgressView()
                    .navigationTitle(String(localized: "select_drink"))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func logDrink() {
        guard let brand = brand, let template = drinkTemplate else { return }
        
        let price = Double(priceText)
        
        let drinkLog = DrinkLog(
            brandId: brand.id,
            brandName: brand.name,
            brandNameZH: brand.nameZH,
            brandEmoji: brand.emoji,
            drinkName: template.name,
            drinkNameZH: template.nameZH,
            size: selectedSize,
            sugarLevel: selectedSugar,
            iceLevel: selectedIce,
            calories: calculatedCalories,
            sugarGrams: calculatedSugar,
            price: price,
            timestamp: Date()
        )
        
        modelContext.insert(drinkLog)
        try? modelContext.save()
        
        // Log to Google Sheets with location (fire-and-forget)
        if let user = authManager.currentUser,
           let email = user.email {
            Task {
                let location = await LocationManager.shared.getLocationForLogging()
                await DrinkLoggerService.shared.logDrink(
                    email: email,
                    name: user.displayName ?? "Unknown",
                    drink: drinkLog,
                    location: location
                )
            }
        }
        
        toastManager.show(String(localized: "logged_toast"))
        onSave()
    }
}

#Preview {
    let brand = Brand(name: "HeyTea", nameZH: "喜茶", emoji: "🍵", isPopular: true)
    let drink = DrinkTemplate(name: "Grape Cheese Tea", nameZH: "芝芝葡萄", baseCalories: 320, baseSugar: 25, brand: brand)
    
    return DrinkOptionsSheet(
        brandId: brand.id,
        drinkTemplateId: drink.id,
        toastManager: ToastManager(),
        onSave: {}
    )
    .environment(LanguageManager.shared)
    .modelContainer(for: [Brand.self, DrinkTemplate.self, DrinkLog.self])
}

//
//  CustomDrinkEntrySheet.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct CustomDrinkEntrySheet: View {
    let toastManager: ToastManager
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    
    @Query(sort: \Brand.name) private var allBrands: [Brand]
    
    @State private var drinkName: String = "Milk Tea"
    @State private var selectedBrand: Brand?
    @State private var customBrandName: String = ""
    @State private var useCustomBrand: Bool = false
    @State private var selectedSize: DrinkSize = .medium
    @State private var selectedSugarLevel: SugarLevel = .regular
    @State private var selectedIce: IceLevel = .regular
    @State private var baseEstimatedCalories: Double = 300
    @State private var calorieOverride: String = ""
    @State private var showOverride: Bool = false
    @State private var priceText: String = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case calorieOverride
        case price
    }
    
    // Computed property that applies multipliers to base estimate
    private var displayedCalories: Double {
        baseEstimatedCalories * selectedSize.multiplier * selectedSugarLevel.multiplier
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Drink Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "drink_name"))
                        .font(.system(size: 16, weight: .semibold))
                    
                    TextField(String(localized: "enter_drink_name"), text: $drinkName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: drinkName) { oldValue, newValue in
                            let estimated = NutritionEstimator.estimate(from: newValue)
                            baseEstimatedCalories = estimated.calories
                        }
                }
                
                // Brand Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "brand_name_optional"))
                        .font(.system(size: 16, weight: .semibold))
                    
                    if useCustomBrand {
                        // Custom brand text field
                        HStack {
                            TextField(String(localized: "enter_brand_name"), text: $customBrandName)
                                .textFieldStyle(.roundedBorder)
                            
                            Button {
                                useCustomBrand = false
                                customBrandName = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        // Brand picker
                        HStack {
                            Picker("Brand", selection: $selectedBrand) {
                                Text(String(localized: "select_brand")).tag(nil as Brand?)
                                ForEach(allBrands, id: \.id) { brand in
                                    Text(languageManager.isEnglish ? brand.name : brand.nameZH).tag(brand as Brand?)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Spacer()
                            
                            Button(String(localized: "other")) {
                                useCustomBrand = true
                                selectedBrand = nil
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                        }
                    }
                }
                
                // Estimation Display and Override
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(String(localized: "estimated_calories"))
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(displayedCalories)) kcal")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Override input (toggleable)
                    if showOverride {
                        HStack(spacing: 8) {
                            TextField(String(localized: "enter_calories"), text: $calorieOverride)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedField, equals: .calorieOverride)
                            
                            Button("Cancel") {
                                showOverride = false
                                calorieOverride = ""
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        }
                    } else {
                        Button(action: { showOverride = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text(String(localized: "override_calories"))
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                        }
                    }
                }
                
                // Size, Sugar, Ice Pickers in a row
                HStack(spacing: 12) {
                    // Size Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "size_label"))
                            .font(.system(size: 14, weight: .semibold))
                        
                        Picker("", selection: $selectedSize) {
                            ForEach(DrinkSize.allCases, id: \.self) { size in
                                Text(size.localizedName).tag(size)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Sugar Level Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "sugar_label"))
                            .font(.system(size: 14, weight: .semibold))
                        
                        Picker("", selection: $selectedSugarLevel) {
                            ForEach(SugarLevel.allCases, id: \.self) { sugar in
                                Text(sugar.localizedName).tag(sugar)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Ice Level Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "ice_label"))
                            .font(.system(size: 14, weight: .semibold))
                        
                        Picker("", selection: $selectedIce) {
                            ForEach(IceLevel.allCases, id: \.self) { ice in
                                Text(ice.localizedName).tag(ice)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // Price Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "price_label"))
                        .font(.system(size: 14, weight: .semibold))
                    
                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                        TextField("0.00", text: $priceText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .price)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: saveQuickLog) {
                        Text(String(localized: "save_custom_drink"))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(drinkName.isEmpty ? Color.gray : Color(red: 0.93, green: 0.26, blue: 0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(drinkName.isEmpty)
                }
            }
            .padding()
            .navigationTitle(String(localized: "custom_drink_title"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialize base estimate for default drink name
                let estimated = NutritionEstimator.estimate(from: drinkName)
                baseEstimatedCalories = estimated.calories
            }
        }
        .presentationDetents([.large])
    }
    
    private func saveQuickLog() {
        // Estimate nutrition from drink name
        let estimated = NutritionEstimator.estimate(from: drinkName)
        
        // Use override if provided, otherwise use estimate
        let finalCalories: Double
        if let override = Double(calorieOverride), !calorieOverride.isEmpty {
            finalCalories = override // Override is final, no multipliers
        } else {
            // Apply multipliers to estimate
            finalCalories = estimated.calories * selectedSize.multiplier * selectedSugarLevel.multiplier
        }
        
        // Sugar always uses multipliers (not overridable)
        let finalSugar = estimated.sugar * selectedSize.multiplier * selectedSugarLevel.multiplier
        
        // Parse price
        let price = Double(priceText)
        
        // Create custom drink template
        let customTemplate = CustomDrinkTemplate(
            name: drinkName,
            nameZH: drinkName,
            customCalories: estimated.calories,
            customSugar: estimated.sugar,
            price: price
        )
        modelContext.insert(customTemplate)
        
        // Determine brand info based on selection
        let finalBrandId: UUID
        let finalBrandName: String
        let finalBrandNameZH: String
        let finalBrandEmoji: String
        
        if useCustomBrand && !customBrandName.isEmpty {
            // Using custom brand name
            finalBrandId = UUID()
            finalBrandName = customBrandName
            finalBrandNameZH = customBrandName
            finalBrandEmoji = "⚡"
        } else if let brand = selectedBrand {
            // Using selected brand from picker
            finalBrandId = brand.id
            finalBrandName = brand.name
            finalBrandNameZH = brand.nameZH
            finalBrandEmoji = brand.emoji
        } else {
            // No brand selected - use Quick Log
            finalBrandId = UUID()
            finalBrandName = "Quick Log"
            finalBrandNameZH = "快速记录"
            finalBrandEmoji = "⚡"
        }
        
        // Create drink log entry
        let drinkLog = DrinkLog(
            brandId: finalBrandId,
            brandName: finalBrandName,
            brandNameZH: finalBrandNameZH,
            brandEmoji: finalBrandEmoji,
            drinkName: drinkName,
            drinkNameZH: drinkName,
            size: selectedSize,
            sugarLevel: selectedSugarLevel,
            iceLevel: selectedIce,
            calories: finalCalories,
            sugarGrams: finalSugar,
            price: price,
            isCustomDrink: true
        )
        
        modelContext.insert(drinkLog)
        try? modelContext.save()
        
        toastManager.show(String(localized: "logged_toast"))
        
        onSave()
        dismiss()
    }
}

#Preview {
    CustomDrinkEntrySheet(toastManager: ToastManager(), onSave: {})
        .environment(LanguageManager.shared)
        .modelContainer(for: [CustomDrinkTemplate.self, DrinkLog.self])
}

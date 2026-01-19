//
//  EditDrinkLogSheet.swift
//  milkTeaTracker
//
//  Created for editing existing drink log entries
//

import SwiftUI
import SwiftData

struct EditDrinkLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    
    let drinkLog: DrinkLog
    let toastManager: ToastManager
    let onSave: () -> Void
    
    @State private var selectedSize: DrinkSize = .medium
    @State private var selectedSugarLevel: SugarLevel = .regular
    @State private var selectedIce: IceLevel = .regular
    @State private var priceText: String = ""
    @State private var calorieText: String = ""
    @State private var sugarText: String = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case calories
        case sugar
        case price
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Drink Info (Read-only)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "drink_name"))
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack {
                            Text(drinkLog.brandEmoji)
                                .font(.system(size: 32))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(languageManager.isEnglish ? drinkLog.drinkName : drinkLog.drinkNameZH)
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Text(languageManager.isEnglish ? drinkLog.brandName : drinkLog.brandNameZH)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                
                // Size Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "size"))
                        .font(.system(size: 16, weight: .semibold))
                    
                    Picker("Size", selection: $selectedSize) {
                        ForEach(DrinkSize.allCases, id: \.self) { size in
                            Text(size.localizedName).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Sugar Level Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "sugar_level"))
                        .font(.system(size: 16, weight: .semibold))
                    
                    Picker("Sugar", selection: $selectedSugarLevel) {
                        ForEach(SugarLevel.allCases, id: \.self) { sugar in
                            Text(sugar.localizedName).tag(sugar)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Ice Level Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "ice_level"))
                        .font(.system(size: 16, weight: .semibold))
                    
                    Picker("Ice", selection: $selectedIce) {
                        ForEach(IceLevel.allCases, id: \.self) { ice in
                            Text(ice.localizedName).tag(ice)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Calories Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "calories"))
                        .font(.system(size: 16, weight: .semibold))
                    
                    HStack {
                        TextField(String(localized: "enter_calories"), text: $calorieText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .calories)
                        
                        Text(String(localized: "kcal_unit"))
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Sugar Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "sugar"))
                        .font(.system(size: 16, weight: .semibold))
                    
                    HStack {
                        TextField(String(localized: "enter_sugar"), text: $sugarText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .sugar)
                        
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Price Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "price"))
                        .font(.system(size: 16, weight: .semibold))
                    
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
                    
                    Button(action: saveChanges) {
                        Text(String(localized: "save_changes"))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.93, green: 0.26, blue: 0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: "edit_drink"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Initialize state when view appears
            selectedSize = drinkLog.size
            selectedSugarLevel = drinkLog.sugarLevel
            selectedIce = drinkLog.iceLevel
            priceText = drinkLog.price.map { String(format: "%.2f", $0) } ?? ""
            calorieText = String(format: "%.0f", drinkLog.calories)
            sugarText = String(format: "%.1f", drinkLog.sugarGrams)
        }
        }
        .presentationDetents([.large])
    }
    
    private func saveChanges() {
        // Update the drinkLog with new values
        drinkLog.size = selectedSize
        drinkLog.sugarLevel = selectedSugarLevel
        drinkLog.iceLevel = selectedIce
        
        // Update calories
        if let calories = Double(calorieText) {
            drinkLog.calories = calories
        }
        
        // Update sugar
        if let sugar = Double(sugarText) {
            drinkLog.sugarGrams = sugar
        }
        
        // Update price
        if let price = Double(priceText), !priceText.isEmpty {
            drinkLog.price = price
        } else {
            drinkLog.price = nil
        }
        
        // Save to model context
        try? modelContext.save()
        
        toastManager.show(String(localized: "drink_updated_toast"))
        onSave()
    }
}

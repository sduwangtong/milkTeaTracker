//
//  CustomDrinkEntrySheet.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData
import VisionKit

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
    @State private var selectedBubble: BubbleLevel = .none
    @State private var baseEstimatedCalories: Double = 300
    @State private var calorieOverride: String = ""
    @State private var showOverride: Bool = false
    @State private var priceText: String = ""
    
    // Receipt scanner state
    @State private var showReceiptSourceSheet: Bool = false
    @State private var showReceiptScanner: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var parsedReceipt: ParsedReceipt?
    @State private var isProcessingReceipt: Bool = false
    @State private var showDrinkSelectionSheet: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case calorieOverride
        case price
    }
    
    // Computed property that applies multipliers to base estimate
    // Formula: (baseCalories * sizeMultiplier * sugarMultiplier) + bubbleCalories
    // Minimum floor of 150 kcal to avoid showing 0 for any drink
    private var displayedCalories: Double {
        let baseCalc = baseEstimatedCalories * selectedSize.multiplier * selectedSugarLevel.multiplier
        let calculated = baseCalc + selectedBubble.calorieAddition
        return max(calculated, 150)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Scan Receipt Button - shows action sheet with multiple source options
                Button(action: { showReceiptSourceSheet = true }) {
                    HStack {
                        if isProcessingReceipt {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 4)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(String(localized: "scan_receipt"))
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.2, green: 0.6, blue: 0.86))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(isProcessingReceipt)
                
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
                
                // Bubble Level Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "bubble_label"))
                        .font(.system(size: 14, weight: .semibold))
                    
                    Picker("", selection: $selectedBubble) {
                        ForEach(BubbleLevel.allCases, id: \.self) { bubble in
                            Text(bubble.localizedName).tag(bubble)
                        }
                    }
                    .pickerStyle(.segmented)
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
            .overlay {
                // Full-screen progress overlay while processing receipt
                if isProcessingReceipt {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            
                            Text(String(localized: "receipt_using_ai"))
                                .foregroundStyle(.white)
                                .font(.headline)
                        }
                        .padding(32)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
        .presentationDetents([.large])
        .confirmationDialog(
            String(localized: "receipt_source_title"),
            isPresented: $showReceiptSourceSheet,
            titleVisibility: .visible
        ) {
            // Camera option - only show if supported
            if isCameraScanningSupported() {
                Button(String(localized: "receipt_source_camera")) {
                    showReceiptScanner = true
                }
            }
            
            // Photo library option
            Button(String(localized: "receipt_source_photos")) {
                showPhotoPicker = true
            }
            
            // Files option
            Button(String(localized: "receipt_source_files")) {
                showFilePicker = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showReceiptScanner) {
            ReceiptScannerView(parsedReceipt: $parsedReceipt, isProcessing: $isProcessingReceipt)
        }
        .sheet(isPresented: $showPhotoPicker) {
            ReceiptPhotoPickerView(parsedReceipt: $parsedReceipt, isProcessing: $isProcessingReceipt)
        }
        .sheet(isPresented: $showFilePicker) {
            ReceiptFilePickerView(parsedReceipt: $parsedReceipt, isProcessing: $isProcessingReceipt)
        }
        .sheet(isPresented: $showDrinkSelectionSheet) {
            if let receipt = parsedReceipt {
                DrinkSelectionFromReceiptSheet(
                    items: receipt.items,
                    brandName: receipt.brandName,
                    onSelect: { selectedItem in
                        applySelectedDrinkItem(selectedItem, from: receipt)
                    }
                )
            }
        }
        .onChange(of: parsedReceipt) { oldValue, newValue in
            handleParsedReceipt(newValue)
        }
    }
    
    /// Handle parsed receipt - show selection if multiple drinks, otherwise apply directly
    private func handleParsedReceipt(_ receipt: ParsedReceipt?) {
        guard let receipt = receipt else { return }
        
        // Check if receipt has any data
        guard receipt.hasAnyData else {
            toastManager.show(String(localized: "receipt_scan_no_data"))
            return
        }
        
        // If multiple drinks found, show selection sheet
        if receipt.items.count > 1 {
            showDrinkSelectionSheet = true
            return
        }
        
        // Single drink or no drinks - apply directly
        if let firstItem = receipt.firstItem {
            applySelectedDrinkItem(firstItem, from: receipt)
        } else {
            // No drinks found, but maybe we have brand or total price
            applyBrandFromReceipt(receipt)
            if let total = receipt.totalPrice {
                priceText = String(format: "%.2f", total)
            }
            toastManager.show(String(localized: "receipt_scanned_success"))
        }
    }
    
    /// Apply a selected drink item to the form
    private func applySelectedDrinkItem(_ item: ParsedReceiptItem, from receipt: ParsedReceipt) {
        // Apply brand first
        applyBrandFromReceipt(receipt)
        
        // Apply drink name
        drinkName = item.drinkName
        
        // Update calorie estimate based on drink name
        let estimated = NutritionEstimator.estimate(from: item.drinkName)
        baseEstimatedCalories = estimated.calories
        
        // Apply size - default to medium if not found
        selectedSize = item.size ?? .medium
        
        // Apply sugar level - default to half sugar (.less = 50%) if not found
        selectedSugarLevel = item.sugarLevel ?? .less
        
        // Apply ice level - default to less ice (.less) if not found
        selectedIce = item.iceLevel ?? .less
        
        // Apply bubble level - default to none if not found
        selectedBubble = item.bubbleLevel ?? .none
        
        // Apply price - use item price or fall back to total
        if let price = item.price {
            priceText = String(format: "%.2f", price)
        } else if let totalPrice = receipt.totalPrice {
            priceText = String(format: "%.2f", totalPrice)
        }
        
        toastManager.show(String(localized: "receipt_scanned_success"))
    }
    
    /// Apply brand from parsed receipt using fuzzy matching
    private func applyBrandFromReceipt(_ receipt: ParsedReceipt) {
        guard let brandName = receipt.brandName else { return }
        
        // Try to find matching brand in database
        let matchedBrand = allBrands.first { brand in
            let brandLower = brand.name.lowercased()
            let parsedLower = brandName.lowercased()
            
            // Check if brand name contains the parsed name or vice versa
            return brandLower.contains(parsedLower) || 
                   parsedLower.contains(brandLower) ||
                   brand.name == brandName
        }
        
        if let matched = matchedBrand {
            selectedBrand = matched
            useCustomBrand = false
        } else {
            // No match found - use as custom brand name
            customBrandName = brandName
            useCustomBrand = true
            selectedBrand = nil
        }
    }
    
    private func saveQuickLog() {
        // Estimate nutrition from drink name
        let estimated = NutritionEstimator.estimate(from: drinkName)
        
        // Use override if provided, otherwise use estimate
        // Formula: (baseCalories * sizeMultiplier * sugarMultiplier) + bubbleCalories
        // Apply minimum floor of 150 kcal to avoid saving 0
        let finalCalories: Double
        if let override = Double(calorieOverride), !calorieOverride.isEmpty {
            finalCalories = max(override, 150) // Override with minimum floor
        } else {
            // Apply multipliers to estimate with bubble addition and minimum floor
            let baseCalc = estimated.calories * selectedSize.multiplier * selectedSugarLevel.multiplier
            let calculated = baseCalc + selectedBubble.calorieAddition
            finalCalories = max(calculated, 150)
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
            bubbleLevel: selectedBubble,
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

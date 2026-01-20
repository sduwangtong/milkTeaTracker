//
//  DrinkSelectionFromReceiptSheet.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/18/26.
//

import SwiftUI

/// Sheet for selecting which drink to log when multiple drinks are found on a receipt
struct DrinkSelectionFromReceiptSheet: View {
    let items: [ParsedReceiptItem]
    let brandName: String?
    let onSelect: (ParsedReceiptItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header info
                if let brand = brandName {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundStyle(.secondary)
                        Text(brand)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                }
                
                // Items count
                Text(String(localized: "multiple_drinks_found"))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                // Drink list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(items) { item in
                            DrinkItemRow(item: item) {
                                onSelect(item)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(String(localized: "select_drink"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Drink Item Row

private struct DrinkItemRow: View {
    let item: ParsedReceiptItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Drink name
                Text(item.drinkName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                // Details row
                HStack(spacing: 12) {
                    // Size
                    if let size = item.size {
                        Label {
                            Text(size.localizedName)
                                .font(.system(size: 13))
                        } icon: {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    // Sugar level
                    if let sugar = item.sugarLevel {
                        Label {
                            Text(sugar.localizedName)
                                .font(.system(size: 13))
                        } icon: {
                            Image(systemName: "cube.fill")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    // Ice level
                    if let ice = item.iceLevel {
                        Label {
                            Text(ice.localizedName)
                                .font(.system(size: 13))
                        } icon: {
                            Image(systemName: "snowflake")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    // Bubble level
                    if let bubble = item.bubbleLevel {
                        Label {
                            Text(bubble.localizedName)
                                .font(.system(size: 13))
                        } icon: {
                            Image(systemName: "circle.grid.2x2.fill")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Price
                    if let price = item.price {
                        Text(String(format: "$%.2f", price))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DrinkSelectionFromReceiptSheet(
        items: [
            ParsedReceiptItem(drinkName: "Bubble Milk Tea", price: 7.26, size: .medium, sugarLevel: .less, iceLevel: .less, bubbleLevel: .regular),
            ParsedReceiptItem(drinkName: "Taro Milk Tea", price: 7.50, size: .large, sugarLevel: .regular, iceLevel: .regular, bubbleLevel: .extra),
            ParsedReceiptItem(drinkName: "Brown Sugar Boba Latte", price: 7.75, size: .small, sugarLevel: .extra, iceLevel: .none, bubbleLevel: .none)
        ],
        brandName: "CoCo Fresh Tea & Juice",
        onSelect: { _ in }
    )
}

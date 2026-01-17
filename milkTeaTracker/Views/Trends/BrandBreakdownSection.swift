//
//  BrandBreakdownSection.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct BrandBreakdownSection: View {
    let breakdown: [BrandBreakdown]
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "brand_breakdown"))
                .font(.system(size: 18, weight: .semibold))
            
            if breakdown.isEmpty {
                Text(String(localized: "no_data_period"))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ForEach(breakdown) { brand in
                    BrandBreakdownRow(brand: brand)
                }
            }
        }
    }
}

#Preview {
    BrandBreakdownSection(breakdown: [
        BrandBreakdown(
            brandId: UUID(),
            brandName: "HeyTea",
            brandNameZH: "喜茶",
            brandEmoji: "🍵",
            cupCount: 8,
            totalSpend: 144,
            percentage: 32
        ),
        BrandBreakdown(
            brandId: UUID(),
            brandName: "Nayuki",
            brandNameZH: "奈雪",
            brandEmoji: "🧋",
            cupCount: 5,
            totalSpend: 110,
            percentage: 20
        )
    ])
    .environment(LanguageManager.shared)
    .padding()
}

//
//  BrandBreakdownRow.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct BrandBreakdownRow: View {
    let brand: BrandBreakdown
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Brand emoji and name
                HStack(spacing: 12) {
                    Text(brand.brandEmoji)
                        .font(.system(size: 32))
                        .frame(width: 50, height: 50)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageManager.isEnglish ? brand.brandName : brand.brandNameZH)
                            .font(.system(size: 17, weight: .medium))
                        
                        Text("\(brand.cupCount) cups • $\(Int(brand.totalSpend))")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Percentage
                Text("\(Int(brand.percentage))%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 0.9))
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(red: 0.9, green: 0.9, blue: 0.92))
                        .frame(height: 8)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.4, blue: 0.9),
                                    Color(red: 0.7, green: 0.35, blue: 0.85)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (brand.percentage / 100), height: 8)
                }
            }
            .frame(height: 8)
            .clipShape(Capsule())
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview {
    BrandBreakdownRow(brand: BrandBreakdown(
        brandId: UUID(),
        brandName: "HeyTea",
        brandNameZH: "喜茶",
        brandEmoji: "🍵",
        cupCount: 8,
        totalSpend: 144,
        percentage: 32
    ))
    .environment(LanguageManager.shared)
    .padding()
}

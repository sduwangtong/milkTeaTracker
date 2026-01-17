//
//  BrandCard.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct BrandCard: View {
    let brand: Brand
    let onTap: () -> Void
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Display logo image if available, otherwise fall back to emoji
                if let logoName = brand.logoImageName {
                    Image(logoName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text(brand.emoji)
                        .font(.system(size: 48))
                }
                
                Text(languageManager.isEnglish ? brand.name : brand.nameZH)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let brand = Brand(name: "HeyTea", nameZH: "喜茶", emoji: "🍵", isPopular: true)
    return BrandCard(brand: brand, onTap: {})
        .padding()
        .environment(LanguageManager.shared)
}

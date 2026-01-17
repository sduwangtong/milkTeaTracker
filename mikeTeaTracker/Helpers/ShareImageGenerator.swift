//
//  ShareImageGenerator.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import UIKit

struct ShareImageGenerator {
    @MainActor
    static func generateImage(from summary: TrendSummary, languageManager: LanguageManager, cupGoal: Int? = nil, calorieGoal: Double? = nil) -> UIImage? {
        // Create the share card view with explicit sizing
        let card = ShareCard(summary: summary, cupGoal: cupGoal, calorieGoal: calorieGoal)
            .environment(languageManager)
            .frame(width: 400, height: 650)
        
        // Create renderer with explicit configuration
        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        
        // Try primary rendering method
        if let image = renderer.uiImage {
            return image
        }
        
        // Fallback: use UIHostingController
        return fallbackRender(summary: summary, languageManager: languageManager, cupGoal: cupGoal, calorieGoal: calorieGoal)
    }
    
    @MainActor
    private static func fallbackRender(summary: TrendSummary, languageManager: LanguageManager, cupGoal: Int?, calorieGoal: Double?) -> UIImage? {
        let card = ShareCard(summary: summary, cupGoal: cupGoal, calorieGoal: calorieGoal)
            .environment(languageManager)
            .frame(width: 400, height: 650)
        
        let controller = UIHostingController(rootView: card)
        let size = CGSize(width: 400, height: 650)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .white
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ShareCard: View {
    let summary: TrendSummary
    let cupGoal: Int?
    let calorieGoal: Double?
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
        ZStack {
            // White background
            Color.white
            
            // Card content with padding
            TrendSummaryCard(summary: summary, cupGoal: cupGoal, calorieGoal: calorieGoal)
                .padding(20)
        }
        .frame(width: 400, height: 650)
    }
}

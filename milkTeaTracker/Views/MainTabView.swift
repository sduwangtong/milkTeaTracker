//
//  MainTabView.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DrinkLogView()
                .tabItem {
                    Label(languageManager.localizedString("drink_log"), systemImage: "cup.and.saucer.fill")
                }
                .tag(0)
            
            LedgerView()
                .tabItem {
                    Label(languageManager.localizedString("ledger"), systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            if FeatureFlags.showTrends {
                TrendsView()
                    .tabItem {
                        Label(languageManager.localizedString("trends"), systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(2)
            }
            
            ProfileView()
                .tabItem {
                    Label(languageManager.localizedString("profile"), systemImage: "person.circle")
                }
                .tag(3)
        }
        .tint(Color(red: 0.93, green: 0.26, blue: 0.55)) // Pink accent color
        .onAppear {
            // Seed sample data on first launch
            SampleData.seedIfNeeded(context: modelContext)
            
            // Request location permission for drink logging
            LocationManager.shared.requestPermission()
        }
    }
}

// Placeholder views for future features
struct LedgerPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Ledger")
                    .font(.title2)
                    .padding(.top)
                Text("Coming soon...")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle(String(localized: "ledger"))
        }
    }
}

struct TrendsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Trends")
                    .font(.title2)
                    .padding(.top)
                Text("Coming soon...")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle(String(localized: "trends"))
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Brand.self, DrinkTemplate.self, DrinkLog.self])
        .environment(LanguageManager.shared)
}

//
//  MainTabView.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DrinkLogView()
                .tabItem {
                    Label(String(localized: "drink_log"), systemImage: "cup.and.saucer.fill")
                }
                .tag(0)
            
            LedgerView()
                .tabItem {
                    Label(String(localized: "ledger"), systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            TrendsView()
                .tabItem {
                    Label(String(localized: "trends"), systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
        }
        .tint(Color(red: 0.93, green: 0.26, blue: 0.55)) // Pink accent color
        .onAppear {
            // Seed sample data on first launch
            SampleData.seedIfNeeded(context: modelContext)
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
}

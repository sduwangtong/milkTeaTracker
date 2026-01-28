//
//  FeatureFlags.swift
//  milkTeaTracker
//
//  Feature flags for controlling feature visibility
//

import Foundation

struct FeatureFlags {
    /// Shows the Popular Brands section and search bar on the home screen
    /// Enable this in the next version
    static let showPopularBrands = false
    
    /// Shows the Trends tab in the main tab bar
    /// Enable this in the next version
    static let showTrends = false
    
    /// Shows ads in the app (can be disabled by in-app purchase)
    /// Set to true to enable AdMob integration
    static let showAds = true
    
    /// Shows banner ads in main views (Ledger, Quick Log)
    /// Set to false to hide ads in these views while keeping other ad functionality
    static let showBannerAdsInMainViews = true
}

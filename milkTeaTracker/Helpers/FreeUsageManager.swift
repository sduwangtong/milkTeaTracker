//
//  FreeUsageManager.swift
//  milkTeaTracker
//
//  Manages free tier usage limits for AI receipt scanning.
//  Free users get 5 scans per week, resetting each Monday.
//

import Foundation

@Observable
class FreeUsageManager {
    static let shared = FreeUsageManager()
    
    // MARK: - Constants
    
    /// Maximum number of free scans allowed per week
    let weeklyLimit = 5
    
    // MARK: - UserDefaults Keys
    
    private let usageCountKey = "free_scan_count"
    private let weekStartKey = "free_scan_week_start"
    
    // MARK: - State
    
    /// Number of scans used this week
    private(set) var scansUsedThisWeek: Int {
        didSet {
            UserDefaults.standard.set(scansUsedThisWeek, forKey: usageCountKey)
        }
    }
    
    /// Start date of the current tracking week
    private var weekStartDate: Date {
        didSet {
            UserDefaults.standard.set(weekStartDate, forKey: weekStartKey)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Number of scans remaining this week
    var remainingScans: Int {
        max(0, weeklyLimit - scansUsedThisWeek)
    }
    
    /// Whether the user can perform a scan
    var canScan: Bool {
        remainingScans > 0
    }
    
    // MARK: - Initialization
    
    init() {
        // Load saved values
        self.scansUsedThisWeek = UserDefaults.standard.integer(forKey: usageCountKey)
        self.weekStartDate = UserDefaults.standard.object(forKey: weekStartKey) as? Date ?? Date()
        
        // Check if we need to reset for a new week
        resetIfNewWeek()
    }
    
    // MARK: - Public Methods
    
    /// Use one scan from the weekly allowance
    /// Call this after a successful Gemini API scan
    func useOneScan() {
        resetIfNewWeek()
        
        guard canScan else { return }
        scansUsedThisWeek += 1
    }
    
    /// Force reset the weekly counter (for testing or admin purposes)
    func resetUsage() {
        scansUsedThisWeek = 0
        weekStartDate = startOfCurrentWeek()
    }
    
    // MARK: - Private Methods
    
    /// Check if we're in a new week and reset the counter if so
    private func resetIfNewWeek() {
        let currentWeekStart = startOfCurrentWeek()
        
        // If the stored week start is before the current week start, reset
        if weekStartDate < currentWeekStart {
            scansUsedThisWeek = 0
            weekStartDate = currentWeekStart
        }
    }
    
    /// Get the start of the current week (Monday at midnight)
    private func startOfCurrentWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the start of the week containing today
        // weekday: 1 = Sunday, 2 = Monday, etc.
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = 2 // Monday
        
        return calendar.date(from: components) ?? now
    }
}

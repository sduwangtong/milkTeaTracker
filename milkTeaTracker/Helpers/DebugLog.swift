//
//  DebugLog.swift
//  milkTeaTracker
//
//  Debug logging utility that only outputs in DEBUG builds.
//  All logging is stripped from release builds for better performance
//  and to avoid exposing internal details in production.
//

import Foundation

/// Debug logging function that only prints in DEBUG builds
/// Usage: debugLog("[Module] Message")
@inline(__always)
func debugLog(_ message: @autoclosure () -> String) {
    #if DEBUG
    print(message())
    #endif
}

/// Debug logging function with multiple items (like print)
/// Usage: debugLog("[Module]", "Message", value)
@inline(__always)
func debugLog(_ items: Any..., separator: String = " ") {
    #if DEBUG
    let message = items.map { String(describing: $0) }.joined(separator: separator)
    print(message)
    #endif
}

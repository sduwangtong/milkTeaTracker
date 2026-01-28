//
//  ToastManager.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

/// Type of toast message to display
enum ToastType {
    case success
    case error
    case warning
    case info
    
    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success: return Color.green.opacity(0.9)
        case .error: return Color.red.opacity(0.9)
        case .warning: return Color.orange.opacity(0.9)
        case .info: return Color.black.opacity(0.8)
        }
    }
}

@Observable
class ToastManager {
    var isShowing = false
    var message = ""
    var toastType: ToastType = .info
    
    func show(_ message: String, type: ToastType = .info, duration: TimeInterval = 2.0) {
        self.message = message
        self.toastType = type
        self.isShowing = true
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            self.isShowing = false
        }
    }
    
    /// Show a success message
    func showSuccess(_ message: String) {
        show(message, type: .success, duration: 1.5)
    }
    
    /// Show an error message
    func showError(_ message: String) {
        show(message, type: .error, duration: 3.0)
    }
    
    /// Show a warning message
    func showWarning(_ message: String) {
        show(message, type: .warning, duration: 2.5)
    }
}

struct ToastView: View {
    let message: String
    var type: ToastType = .info
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: type.iconName)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message)
                .font(.system(size: 15, weight: .medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(type.backgroundColor)
        .clipShape(Capsule())
    }
}

struct ToastModifier: ViewModifier {
    @Bindable var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if toastManager.isShowing {
                VStack {
                    Spacer()
                    ToastView(message: toastManager.message, type: toastManager.toastType)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 50)
                }
                .animation(.spring(duration: 0.3), value: toastManager.isShowing)
            }
        }
    }
}

extension View {
    func toast(_ toastManager: ToastManager) -> some View {
        modifier(ToastModifier(toastManager: toastManager))
    }
}

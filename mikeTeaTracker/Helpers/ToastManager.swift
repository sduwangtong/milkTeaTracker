//
//  ToastManager.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

@Observable
class ToastManager {
    var isShowing = false
    var message = ""
    
    func show(_ message: String, duration: TimeInterval = 1.5) {
        self.message = message
        self.isShowing = true
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            self.isShowing = false
        }
    }
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))
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
                    ToastView(message: toastManager.message)
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

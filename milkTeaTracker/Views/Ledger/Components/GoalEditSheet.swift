//
//  GoalEditSheet.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI

struct GoalEditSheet: View {
    let currentValue: Int?
    let unit: String
    let onSave: (Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var languageManager
    @State private var goalText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(languageManager.localizedString(unit == "cups" ? "enter_cup_goal" : "enter_calorie_goal"))
                        .font(.system(size: 16, weight: .semibold))
                    
                    TextField("0", text: $goalText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 18))
                        .focused($isFocused)
                }
                
                Spacer()
                
                Button(action: saveGoal) {
                    Text(languageManager.localizedString("save"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(goalText.isEmpty ? Color.gray : Color(red: 0.93, green: 0.26, blue: 0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(goalText.isEmpty)
            }
            .padding()
            .navigationTitle(languageManager.localizedString("edit_goal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.localizedString("cancel")) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let current = currentValue {
                    goalText = "\(current)"
                }
                isFocused = true
            }
        }
        .presentationDetents([.height(300)])
    }
    
    private func saveGoal() {
        if let value = Int(goalText), value > 0 {
            onSave(value)
            dismiss()
        }
    }
}

#Preview {
    GoalEditSheet(currentValue: 20, unit: "cups") { _ in }
}

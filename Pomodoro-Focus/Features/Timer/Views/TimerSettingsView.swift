//
//  TimerSettingsView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI

struct TimerSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    private let design = DesignSystem.shared
    
    var body: some View {
        List {
            Section {
                DurationPicker(
                    title: "Focus Duration",
                    icon: "brain.head.profile",
                    color: design.colors.focus,
                    value: $viewModel.focusDuration,
                    range: 1...60,
                    isPremium: !viewModel.isPremium && viewModel.focusDuration != 25
                ) { newValue in
                    viewModel.saveFocusDuration(newValue)
                }
            } header: {
                Text("Focus Session")
            } footer: {
                Text("Recommended: 25 minutes (classic Pomodoro)")
                    .font(design.typography.caption)
            }
            
            Section {
                DurationPicker(
                    title: "Short Break",
                    icon: "cup.and.saucer.fill",
                    color: design.colors.shortBreak,
                    value: $viewModel.shortBreakDuration,
                    range: 1...15,
                    isPremium: !viewModel.isPremium && viewModel.shortBreakDuration != 5
                ) { newValue in
                    viewModel.saveShortBreakDuration(newValue)
                }
                
                DurationPicker(
                    title: "Long Break",
                    icon: "powersleep",
                    color: design.colors.longBreak,
                    value: $viewModel.longBreakDuration,
                    range: 5...30,
                    isPremium: !viewModel.isPremium && viewModel.longBreakDuration != 15
                ) { newValue in
                    viewModel.saveLongBreakDuration(newValue)
                }
            } header: {
                Text("Break Sessions")
            }
            
            Section {
                Stepper(value: $viewModel.longBreakInterval, in: 2...10) {
                    HStack {
                        Image(systemName: "repeat")
                            .foregroundColor(design.colors.primary)
                        
                        Text("Long break after")
                        
                        Spacer()
                        
                        Text("\(viewModel.longBreakInterval) sessions")
                            .foregroundColor(design.colors.textSecondary)
                    }
                }
                .onChange(of: viewModel.longBreakInterval) { newValue in
                    viewModel.saveLongBreakInterval(newValue)
                }
            } header: {
                Text("Intervals")
            } footer: {
                Text("Take a long break after this many focus sessions")
            }
            
            Section {
                Button(action: {
                    withAnimation {
                        viewModel.resetToDefaults()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset to Defaults")
                    }
                    .foregroundColor(design.colors.error)
                }
            }
        }
        .navigationTitle("Timer Durations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Duration Picker Component

struct DurationPicker: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var value: Int
    let range: ClosedRange<Int>
    let isPremium: Bool
    let onChange: (Int) -> Void
    
    private let design = DesignSystem.shared
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(design.typography.body)
            
            Spacer()
            
            if isPremium {
                PremiumBadge()
            } else {
                Picker("", selection: $value) {
                    ForEach(Array(range), id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: value) { newValue in
                    onChange(newValue)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        TimerSettingsView(viewModel: SettingsViewModel())
    }
}

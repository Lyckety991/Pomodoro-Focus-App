//
//  FocusModeView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 15.02.26.
//

import SwiftUI

struct FocusModeView: View {
    @ObservedObject var timerService: TimerService
    @Environment(\.dismiss) var dismiss
    @State private var showExitWarning = false
    
    private let design = DesignSystem.shared
    
    var body: some View {
        ZStack {
            // Fullscreen Background
            timerModeColor
                .ignoresSafeArea()
            
            VStack(spacing: design.spacing.xl) {
                Spacer()
                
                // Large Timer Display
                VStack(spacing: design.spacing.lg) {
                    Text(timerService.currentMode.displayName)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Giant Timer
                    Text(timerService.formattedTime)
                        .font(.system(size: 96, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    // Progress Bar
                    ProgressView(value: timerService.progress)
                        .tint(.white)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .frame(width: 200)
                    
                    // Motivational Message
                    motivationalMessage
                        .font(design.typography.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, design.spacing.xl)
                }
                
                Spacer()
                
                // Minimal Controls
                HStack(spacing: design.spacing.xl) {
                    Button(action: {
                        showExitWarning = true
                    }) {
                        Text("Exit Focus")
                            .font(design.typography.body)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, design.spacing.xxl)
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            // ✅ Force screen awake in Focus Mode
            ScreenWakeService.shared.keepScreenAwake()
        }
        .onDisappear {
            // ✅ Restore normal behavior
            if timerService.timerState != .running {
                ScreenWakeService.shared.allowScreenSleep()
            }
        }
        .alert("Leave Focus Mode?", isPresented: $showExitWarning) {
            Button("Stay Focused", role: .cancel) {}
            Button("Leave", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You're doing great! Are you sure you want to exit?")
        }
    }
    
    private var timerModeColor: Color {
        switch timerService.currentMode {
        case .focus:
            return design.colors.focus
        case .shortBreak:
            return design.colors.shortBreak
        case .longBreak:
            return design.colors.longBreak
        }
    }
    
    private var motivationalMessage: some View {
        let messages = [
            "Stay focused. You got this! 💪",
            "Deep work in progress... 🧠",
            "Distractions can wait. Keep going! 🎯",
            "Your future self will thank you. ✨",
            "Focus is a superpower. Use it! ⚡️",
        ]
        
        return Text(messages.randomElement() ?? "Stay focused!")
    }
}

#Preview {
    FocusModeView(timerService: TimerService())
}

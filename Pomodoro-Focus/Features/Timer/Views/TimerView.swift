//
//  TimerView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation
import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    
    private let design = DesignSystem.shared
    
    var body: some View {
        ZStack {
            // Background
            viewModel.currentModeColor
                .opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: design.spacing.xl) {
                // Header
                headerView
                
                Spacer()
                
                // Main Timer Circle
                timerCircleView
                
                Spacer()
                
                // Controls
                controlsView
                
                // Bottom Stats
                statsView
                    .padding(.bottom, design.spacing.lg)
            }
            .padding(.horizontal, design.spacing.lg)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel.showStatistics = true }) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(design.colors.textPrimary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(design.colors.textPrimary)
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $viewModel.showStatistics) {
            StatisticsView()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: design.spacing.sm) {
            Text(viewModel.timerService.currentMode.displayName)
                .font(design.typography.title1)
                .foregroundColor(design.colors.textPrimary)
            
            if viewModel.timerService.currentMode == .focus {
                Text("Session #\(viewModel.timerService.sessionsCompleted + 1)")
                    .font(design.typography.caption)
                    .foregroundColor(design.colors.textSecondary)
            }
        }
        .padding(.top, design.spacing.lg)
    }
    
    // MARK: - Timer Circle
    
    private var timerCircleView: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    viewModel.currentModeColor.opacity(0.2),
                    lineWidth: 12
                )
            
            // Progress Circle
            Circle()
                .trim(from: 0, to: viewModel.timerService.progress)
                .stroke(
                    viewModel.currentModeColor,
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: viewModel.timerService.progress)
            
            // Time Display
            VStack(spacing: design.spacing.sm) {
                Text(viewModel.timerService.formattedTime)
                    .font(design.typography.timerDisplay)
                    .foregroundColor(design.colors.textPrimary)
                    .monospacedDigit()
                
                if viewModel.timerService.timerState == .paused {
                    Text("Paused")
                        .font(design.typography.caption)
                        .foregroundColor(design.colors.textSecondary)
                }
            }
        }
        .frame(width: 280, height: 280)
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        HStack(spacing: design.spacing.xl) {
            // Reset Button
            Button(action: {
                viewModel.resetTimer()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(viewModel.canReset ? design.colors.textPrimary : design.colors.textSecondary.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .background(design.colors.surface)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .disabled(!viewModel.canReset)
            
            // Play/Pause Button
            Button(action: {
                viewModel.toggleTimer()
            }) {
                Image(systemName: viewModel.buttonIcon)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(viewModel.currentModeColor)
                    .clipShape(Circle())
                    .shadow(color: viewModel.currentModeColor.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .scaleEffect(viewModel.timerService.timerState == .running ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: viewModel.timerService.timerState)
            
            // Skip Button
            Button(action: {
                viewModel.skipSession()
            }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(design.colors.textPrimary)
                    .frame(width: 60, height: 60)
                    .background(design.colors.surface)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Stats
    
    private var statsView: some View {
        HStack(spacing: design.spacing.xl) {
            StatCard(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.timerService.sessionsCompleted)",
                label: "Today"
            )
            
            StatCard(
                icon: "flame.fill",
                value: "\(calculateStreak())",
                label: "Streak"
            )
        }
        .padding(.horizontal, design.spacing.lg)
    }
    
    private func calculateStreak() -> Int {
        // TODO: Implement streak calculation from Core Data
        return 0
    }
}

// MARK: - StatCard

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    private let design = DesignSystem.shared
    
    var body: some View {
        HStack(spacing: design.spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(design.colors.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(design.typography.title2)
                    .foregroundColor(design.colors.textPrimary)
                
                Text(label)
                    .font(design.typography.caption)
                    .foregroundColor(design.colors.textSecondary)
            }
        }
        .padding(design.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(design.colors.surface)
        .cornerRadius(design.cornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        TimerView()
    }
}

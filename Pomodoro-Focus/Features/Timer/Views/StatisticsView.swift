//
//  StatisticsView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @Environment(\.dismiss) var dismiss
    
    private let design = DesignSystem.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: design.spacing.xl) {
                    // Stats Cards
                    statsCardsSection
                    
                    // Chart Section
                    chartSection
                    
                    // Today's Sessions
                    if !viewModel.todaySessions.isEmpty {
                        todaySessionsSection
                    }
                    
                    // Streaks Section
                    streaksSection
                }
                .padding(design.spacing.lg)
            }
            .background(design.colors.background)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.fetchAllData()
            }
        }
    }
    
    // MARK: - Stats Cards
    
    private var statsCardsSection: some View {
        VStack(spacing: design.spacing.md) {
            HStack(spacing: design.spacing.md) {
                StatsInfoCard(
                    icon: "flame.fill",
                    iconColor: design.colors.focus,
                    title: "Today",
                    value: viewModel.formatDuration(viewModel.todayFocusTime),
                    subtitle: "\(viewModel.todaySessions.count) sessions"
                )
                
                StatsInfoCard(
                    icon: "calendar",
                    iconColor: design.colors.shortBreak,
                    title: "This Week",
                    value: viewModel.formatDuration(viewModel.weekFocusTime),
                    subtitle: "\(viewModel.weekSessions.count) sessions"
                )
            }
            
            StatsInfoCard(
                icon: "clock.fill",
                iconColor: design.colors.longBreak,
                title: "Total Focus Time",
                value: viewModel.formatDuration(viewModel.totalFocusTime),
                subtitle: "All time"
            )
        }
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: design.spacing.md) {
            // Time Range Picker
            Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                ForEach(StatisticsViewModel.TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedTimeRange) { _ in
                withAnimation {
                    viewModel.fetchAllData()
                }
            }
            
            // Chart
            VStack(alignment: .leading, spacing: design.spacing.sm) {
                Text("Focus Time")
                    .font(design.typography.title3)
                    .foregroundColor(design.colors.textPrimary)
                
                ChartView(data: viewModel.getChartData())
                    .frame(height: 220)
            }
            .padding(design.spacing.lg)
            .background(design.colors.surface)
            .cornerRadius(design.cornerRadius.lg)
        }
    }
    
    // MARK: - Today's Sessions
    
    private var todaySessionsSection: some View {
        VStack(alignment: .leading, spacing: design.spacing.md) {
            Text("Today's Sessions")
                .font(design.typography.title3)
                .foregroundColor(design.colors.textPrimary)
            
            VStack(spacing: design.spacing.sm) {
                ForEach(viewModel.todaySessions) { session in
                    SessionRow(session: session)
                }
            }
        }
    }
    
    // MARK: - Streaks Section
    
    private var streaksSection: some View {
        VStack(spacing: design.spacing.md) {
            HStack(spacing: design.spacing.md) {
                StreakCard(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(viewModel.currentStreak)",
                    subtitle: viewModel.currentStreak == 1 ? "day" : "days",
                    color: design.colors.focus
                )
                
                StreakCard(
                    icon: "trophy.fill",
                    title: "Best Streak",
                    value: "\(viewModel.longestStreak)",
                    subtitle: viewModel.longestStreak == 1 ? "day" : "days",
                    color: .yellow
                )
            }
        }
    }
}

// MARK: - Enhanced Stat Card (renamed to avoid clash with TimerView.StatCard)

struct StatsInfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    private let design = DesignSystem.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: design.spacing.md) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(design.typography.caption)
                    .foregroundColor(design.colors.textSecondary)
                
                Text(value)
                    .font(design.typography.title2)
                    .foregroundColor(design.colors.textPrimary)
                
                Text(subtitle)
                    .font(design.typography.caption)
                    .foregroundColor(design.colors.textSecondary)
            }
        }
        .padding(design.spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(design.colors.surface)
        .cornerRadius(design.cornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: FocusSession
    
    private let design = DesignSystem.shared
    
    var body: some View {
        HStack(spacing: design.spacing.md) {
            // Mode Icon
            Image(systemName: modeIcon)
                .font(.system(size: 20))
                .foregroundColor(modeColor)
                .frame(width: 40, height: 40)
                .background(modeColor.opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.timerMode?.capitalized ?? "Focus")
                    .font(design.typography.bodyBold)
                    .foregroundColor(design.colors.textPrimary)
                
                Text(formatTime(session.startTime))
                    .font(design.typography.caption)
                    .foregroundColor(design.colors.textSecondary)
            }
            
            Spacer()
            
            Text(formatDuration(Int(session.duration)))
                .font(design.typography.bodyBold)
                .foregroundColor(design.colors.textPrimary)
        }
        .padding(design.spacing.md)
        .background(design.colors.surface)
        .cornerRadius(design.cornerRadius.md)
    }
    
    private var modeIcon: String {
        switch session.timerMode {
        case "focus": return "brain.head.profile"
        case "shortBreak": return "cup.and.saucer.fill"
        case "longBreak": return "powersleep"
        default: return "timer"
        }
    }
    
    private var modeColor: Color {
        switch session.timerMode {
        case "focus": return design.colors.focus
        case "shortBreak": return design.colors.shortBreak
        case "longBreak": return design.colors.longBreak
        default: return design.colors.primary
        }
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes)m"
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    private let design = DesignSystem.shared
    
    var body: some View {
        VStack(spacing: design.spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(design.colors.textPrimary)
                
                Text(subtitle)
                    .font(design.typography.caption)
                    .foregroundColor(design.colors.textSecondary)
            }
            
            Text(title)
                .font(design.typography.caption)
                .foregroundColor(design.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(design.spacing.lg)
        .background(design.colors.surface)
        .cornerRadius(design.cornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    StatisticsView()
}

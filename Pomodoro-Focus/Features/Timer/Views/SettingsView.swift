//
//  SettingsView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    private let design = DesignSystem.shared
    
    var body: some View {
        NavigationView {
            List {
                // Timer Settings Section
                Section {
                    NavigationLink(destination: TimerSettingsView(viewModel: viewModel)) {
                        SettingsRow(
                            icon: "timer",
                            iconColor: design.colors.focus,
                            title: "Timer Durations",
                            subtitle: "\(viewModel.focusDuration)m Focus"
                        )
                    }
                } header: {
                    Text("Timer")
                }
                
                // Audio Settings Section
                Section {
                    NavigationLink(destination: SoundSettingsView(viewModel: viewModel)) {
                        SettingsRow(
                            icon: "speaker.wave.2.fill",
                            iconColor: design.colors.shortBreak,
                            title: "Sounds & Audio",
                            subtitle: viewModel.selectedSound == "none" ? "Off" : "Ambient Sounds"
                        )
                    }
                    
                    Toggle(isOn: $viewModel.notificationSound) {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: design.colors.warning,
                            title: "Notification Sound",
                            subtitle: nil
                        )
                    }
                    .tint(design.colors.primary)
                    .onChange(of: viewModel.notificationSound) { newValue in
                        viewModel.saveNotificationSound(newValue)
                    }
                } header: {
                    Text("Audio & Notifications")
                }
                
                // Appearance Section
                Section {
                    NavigationLink(destination: ThemeSettingsView(viewModel: viewModel)) {
                        HStack {
                            SettingsRow(
                                icon: "paintbrush.fill",
                                iconColor: design.colors.longBreak,
                                title: "Theme",
                                subtitle: viewModel.selectedTheme.capitalized
                            )
                            
                            if !viewModel.isPremium {
                                PremiumBadge()
                            }
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                // Premium Section
                if !viewModel.isPremium {
                    Section {
                        Button(action: {
                            viewModel.unlockPremium()
                        }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Unlock Premium")
                                        .font(design.typography.bodyBold)
                                        .foregroundColor(design.colors.textPrimary)
                                    
                                    Text("Custom timers, themes & more")
                                        .font(design.typography.caption)
                                        .foregroundColor(design.colors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(design.colors.textSecondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                // App Info Section
                Section {
                    Button(action: {
                        viewModel.restorePurchases()
                    }) {
                        SettingsRow(
                            icon: "arrow.clockwise",
                            iconColor: design.colors.primary,
                            title: "Restore Purchases",
                            subtitle: nil
                        )
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: design.colors.textSecondary,
                            title: "About FlowTimer",
                            subtitle: "Version 1.0.0"
                        )
                    }
                    
                    Link(destination: URL(string: "https://your-privacy-policy.com")!) {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            iconColor: design.colors.textSecondary,
                            title: "Privacy Policy",
                            subtitle: nil
                        )
                    }
                } header: {
                    Text("Support")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    
    private let design = DesignSystem.shared
    
    var body: some View {
        HStack(spacing: design.spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(design.typography.body)
                    .foregroundColor(design.colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(design.typography.caption)
                        .foregroundColor(design.colors.textSecondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Premium Badge

struct PremiumBadge: View {
    private let design = DesignSystem.shared
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10))
            Text("PRO")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [Color.yellow, Color.orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

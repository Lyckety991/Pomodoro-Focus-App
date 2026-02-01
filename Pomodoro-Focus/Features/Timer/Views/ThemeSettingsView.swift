//
//  ThemeSettingsView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI

struct ThemeSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    private let design = DesignSystem.shared
    
    private let themes = [
        ThemeOption(id: "default", name: "Default", isPremium: false, primaryColor: Color.red),
        ThemeOption(id: "ocean", name: "Ocean Blue", isPremium: true, primaryColor: Color.blue),
        ThemeOption(id: "forest", name: "Forest Green", isPremium: true, primaryColor: Color.green),
        ThemeOption(id: "sunset", name: "Sunset Orange", isPremium: true, primaryColor: Color.orange),
        ThemeOption(id: "purple", name: "Purple Dream", isPremium: true, primaryColor: Color.purple),
    ]
    
    var body: some View {
        List {
            Section {
                ForEach(themes) { theme in
                    ThemeRow(
                        theme: theme,
                        isSelected: viewModel.selectedTheme == theme.id,
                        isPremiumUser: viewModel.isPremium
                    ) {
                        viewModel.saveTheme(theme.id)
                    }
                }
            } header: {
                Text("Color Themes")
            } footer: {
                Text("Premium themes unlock custom color schemes throughout the app")
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Theme Option Model

struct ThemeOption: Identifiable {
    let id: String
    let name: String
    let isPremium: Bool
    let primaryColor: Color
}

// MARK: - Theme Row

struct ThemeRow: View {
    let theme: ThemeOption
    let isSelected: Bool
    let isPremiumUser: Bool
    let onTap: () -> Void
    
    private let design = DesignSystem.shared
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: design.spacing.md) {
                // Color Preview
                Circle()
                    .fill(theme.primaryColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .opacity(isSelected ? 1 : 0)
                    )
                
                Text(theme.name)
                    .font(design.typography.body)
                    .foregroundColor(design.colors.textPrimary)
                
                Spacer()
                
                if theme.isPremium && !isPremiumUser {
                    PremiumBadge()
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(design.colors.primary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ThemeSettingsView(viewModel: SettingsViewModel())
    }
}

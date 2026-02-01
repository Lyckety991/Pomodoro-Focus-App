//
//  AboutView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI

struct AboutView: View {
    private let design = DesignSystem.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: design.spacing.xl) {
                // App Icon
                Image(systemName: "timer")
                    .font(.system(size: 80))
                    .foregroundColor(design.colors.primary)
                    .padding(design.spacing.xl)
                    .background(design.colors.surface)
                    .cornerRadius(20)
                
                // App Info
                VStack(spacing: design.spacing.sm) {
                    Text("FlowTimer")
                        .font(design.typography.title1)
                    
                    Text("Version 1.0.0")
                        .font(design.typography.caption)
                        .foregroundColor(design.colors.textSecondary)
                }
                
                // Description
                Text("Focus better with the Pomodoro Technique. Stay productive, take breaks, and achieve your goals.")
                    .font(design.typography.body)
                    .foregroundColor(design.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, design.spacing.xl)
                
                // Links
                VStack(spacing: design.spacing.md) {
                    AboutLink(icon: "envelope.fill", title: "Contact Support", url: "mailto:support@flowtimer.app")
                    AboutLink(icon: "star.fill", title: "Rate on App Store", url: "https://apps.apple.com")
                    AboutLink(icon: "globe", title: "Visit Website", url: "https://flowtimer.app")
                }
                .padding(.top, design.spacing.lg)
                
                // Credits
                Text("Made with ❤️ by Your Name")
                    .font(design.typography.caption)
                    .foregroundColor(design.colors.textSecondary)
                    .padding(.top, design.spacing.xl)
            }
            .padding(design.spacing.lg)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutLink: View {
    let icon: String
    let title: String
    let url: String
    
    private let design = DesignSystem.shared
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(design.colors.primary)
                    .frame(width: 30)
                
                Text(title)
                    .font(design.typography.body)
                    .foregroundColor(design.colors.textPrimary)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(design.colors.textSecondary)
            }
            .padding(design.spacing.md)
            .background(design.colors.surface)
            .cornerRadius(design.cornerRadius.md)
        }
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}

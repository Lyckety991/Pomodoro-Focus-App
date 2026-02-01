//
//  PayWallView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()
    @Environment(\.dismiss) var dismiss
    
    private let design = DesignSystem.shared
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    design.colors.primary.opacity(0.8),
                    design.colors.longBreak.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: design.spacing.xl) {
                    // Header
                    headerView
                    
                    // Features List
                    featuresView
                    
                    // Pricing Options
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(design.spacing.xxl)
                    } else {
                        pricingView
                    }
                    
                    // CTA Button
                    ctaButton
                    
                    // Restore & Terms
                    footerView
                }
                .padding(design.spacing.lg)
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(design.spacing.lg)
                }
                Spacer()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success!", isPresented: $viewModel.showSuccess) {
            Button("Continue") {
                dismiss()
            }
        } message: {
            Text(viewModel.successMessage)
        }
        .onAppear {
            viewModel.loadOfferings()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: design.spacing.md) {
            Image(systemName: "crown.fill")
                .font(.system(size: 64))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 20)
            
            Text("Unlock Premium")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Focus better with advanced features")
                .font(design.typography.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(.top, design.spacing.xxl)
    }
    
    // MARK: - Features
    
    private var featuresView: some View {
        VStack(spacing: design.spacing.md) {
            FeatureRow(
                icon: "timer",
                title: "Custom Timer Lengths",
                description: "Set any duration for focus and break sessions"
            )
            
            FeatureRow(
                icon: "speaker.wave.3.fill",
                title: "Premium Sounds",
                description: "Forest, fireplace, café, and white noise"
            )
            
            FeatureRow(
                icon: "paintbrush.fill",
                title: "Beautiful Themes",
                description: "5 exclusive color themes"
            )
            
            FeatureRow(
                icon: "chart.bar.fill",
                title: "Advanced Statistics",
                description: "Detailed insights and progress tracking"
            )
            
            FeatureRow(
                icon: "icloud.fill",
                title: "Cloud Sync",
                description: "Access your data across all devices"
            )
            
            FeatureRow(
                icon: "heart.fill",
                title: "Support Development",
                description: "Help us build more amazing features"
            )
        }
        .padding(design.spacing.lg)
        .background(Color.white.opacity(0.1))
        .cornerRadius(design.cornerRadius.xl)
    }
    
    // MARK: - Pricing
    
    private var pricingView: some View {
        VStack(spacing: design.spacing.md) {
            if let packages = viewModel.packages {
                ForEach(packages, id: \.identifier) { package in
                    PricingCard(
                        package: package,
                        isSelected: viewModel.selectedPackage?.identifier == package.identifier,
                        onTap: {
                            viewModel.selectPackage(package)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - CTA Button
    
    private var ctaButton: some View {
        Button(action: {
            viewModel.purchase()
        }) {
            HStack {
                if viewModel.isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Start Free Trial")
                        .font(design.typography.title3)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(design.colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(design.cornerRadius.lg)
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        }
        .disabled(viewModel.selectedPackage == nil || viewModel.isPurchasing)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: design.spacing.md) {
            Button(action: {
                viewModel.restore()
            }) {
                Text("Restore Purchases")
                    .font(design.typography.body)
                    .foregroundColor(.white)
                    .underline()
            }
            .disabled(viewModel.isPurchasing)
            
            HStack(spacing: design.spacing.md) {
                Link("Terms", destination: URL(string: "https://your-terms-url.com")!)
                    .font(design.typography.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("•")
                    .foregroundColor(.white.opacity(0.7))
                
                Link("Privacy", destination: URL(string: "https://your-privacy-url.com")!)
                    .font(design.typography.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.bottom, design.spacing.lg)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    private let design = DesignSystem.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: design.spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.yellow)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(design.typography.bodyBold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(design.typography.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

// MARK: - Pricing Card

struct PricingCard: View {
    let package: Package
    let isSelected: Bool
    let onTap: () -> Void
    
    private let design = DesignSystem.shared
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(packageTitle)
                            .font(design.typography.title3)
                            .foregroundColor(.white)
                        
                        if showBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(design.colors.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(packagePrice)
                        .font(design.typography.body)
                        .foregroundColor(.white.opacity(0.9))
                    
                    if let trialText = trialText {
                        Text(trialText)
                            .font(design.typography.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .yellow : .white.opacity(0.5))
            }
            .padding(design.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: design.cornerRadius.lg)
                    .fill(Color.white.opacity(isSelected ? 0.25 : 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: design.cornerRadius.lg)
                            .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
    
    private var packageTitle: String {
        switch package.packageType {
        case .monthly: return "Monthly"
        case .annual: return "Yearly"
        case .lifetime: return "Lifetime"
        default: return package.storeProduct.localizedTitle
        }
    }
    
    private var packagePrice: String {
        switch package.packageType {
        case .monthly:
            return "\(package.storeProduct.localizedPriceString) / month"
        case .annual:
            let monthly = (NSDecimalNumber(decimal: package.storeProduct.price).doubleValue / 12)
            return "\(package.storeProduct.localizedPriceString) / year (~\(formattedPrice(monthly)) / month)"
        case .lifetime:
            return "\(package.storeProduct.localizedPriceString) - Pay once, use forever"
        default:
            return package.storeProduct.localizedPriceString
        }
    }
    
    private var trialText: String? {
        if let intro = package.storeProduct.introductoryDiscount,
           intro.paymentMode == .freeTrial {
            let period = intro.subscriptionPeriod
            return "\(period.value) \(periodUnit(period.unit)) free trial"
        }
        return nil
    }
    
    private var showBestValue: Bool {
        package.packageType == .annual
    }
    
    private func formattedPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = package.storeProduct.priceFormatter?.locale ?? Locale.current
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    private func periodUnit(_ unit: SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}

//
//  PaywallViewModel.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI
import RevenueCat
internal import Combine

class PaywallViewModel: ObservableObject {
    @Published var packages: [Package]?
    @Published var selectedPackage: Package?
    @Published var isLoading: Bool = false
    @Published var isPurchasing: Bool = false
    @Published var showError: Bool = false
    @Published var showSuccess: Bool = false
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    
    private let revenueCat = RevenueCatService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        revenueCat.$offerings
            .sink { [weak self] offerings in
                self?.processOfferings(offerings)
            }
            .store(in: &cancellables)
        
        revenueCat.$isLoading
            .assign(to: &$isLoading)
    }
    
    func loadOfferings() {
        revenueCat.fetchOfferings()
    }
    
    private func processOfferings(_ offerings: Offerings?) {
        guard let offering = offerings?.current else {
            print("⚠️ No current offering found")
            return
        }
        
        // Sort packages: Monthly, Yearly, Lifetime
        var sortedPackages: [Package] = []
        
        if let monthly = offering.monthly {
            sortedPackages.append(monthly)
        }
        
        if let annual = offering.annual {
            sortedPackages.append(annual)
        }
        
        if let lifetime = offering.lifetime {
            sortedPackages.append(lifetime)
        }
        
        packages = sortedPackages
        
        // Auto-select yearly (best value)
        selectedPackage = offering.annual ?? sortedPackages.first
    }
    
    func selectPackage(_ package: Package) {
        withAnimation {
            selectedPackage = package
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func purchase() {
        guard let package = selectedPackage else {
            showError(message: "Please select a plan")
            return
        }
        
        isPurchasing = true
        
        revenueCat.purchase(package: package) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isPurchasing = false
                
                switch result {
                case .success(let purchased):
                    if purchased {
                        self.showSuccess(message: "Welcome to Premium! 🎉")
                        
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                    
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
    
    func restore() {
        isPurchasing = true
        
        revenueCat.restorePurchases { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isPurchasing = false
                
                switch result {
                case .success(let restored):
                    if restored {
                        self.showSuccess(message: "Purchases restored successfully!")
                    } else {
                        self.showError(message: "No purchases found to restore")
                    }
                    
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func showSuccess(message: String) {
        successMessage = message
        showSuccess = true
    }
}

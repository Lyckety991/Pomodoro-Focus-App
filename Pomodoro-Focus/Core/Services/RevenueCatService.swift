//
//  RevenueCatService.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import RevenueCat
import StoreKit
import SwiftUI
internal import Combine

class RevenueCatService: NSObject, ObservableObject {
    var objectWillChange: ObservableObjectPublisher
    
    static let shared = RevenueCatService()
    
    @Published var isPremium: Bool = false
    @Published var offerings: Offerings?
    @Published var isLoading: Bool = false
    
    private let premiumEntitlementID = "premium"
    
    private override init() {
        self.objectWillChange = ObservableObjectPublisher()
        super.init()
    }
    
    func configure() {
        // TODO: Ersetze mit deinem echten API Key
        let apiKey = "YOUR_REVENUECAT_PUBLIC_API_KEY"
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        
        // Listener für Customer Info Updates
        Purchases.shared.delegate = self
        
        checkSubscriptionStatus()
        fetchOfferings()
    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching customer info: \(error.localizedDescription)")
                return
            }
            
            let isPremium = customerInfo?.entitlements[self.premiumEntitlementID]?.isActive == true
            
            DispatchQueue.main.async {
                self.isPremium = isPremium
                UserDefaultsManager.shared.isPremium = isPremium
                print(isPremium ? "✅ User is Premium" : "ℹ️ User is Free")
            }
        }
    }
    
    func fetchOfferings() {
        isLoading = true
        
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("❌ Error fetching offerings: \(error.localizedDescription)")
                    return
                }
                
                self.offerings = offerings
                print("✅ Offerings loaded: \(offerings?.current?.availablePackages.count ?? 0) packages")
            }
        }
    }
    
    func purchase(package: Package, completion: @escaping (Result<Bool, Error>) -> Void) {
        isLoading = true
        
        Purchases.shared.purchase(package: package) { [weak self] transaction, customerInfo, error, userCancelled in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if userCancelled {
                    print("ℹ️ User cancelled purchase")
                    completion(.success(false))
                    return
                }
                
                if let error = error {
                    print("❌ Purchase error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let isPremium = customerInfo?.entitlements[self.premiumEntitlementID]?.isActive == true
                self.isPremium = isPremium
                UserDefaultsManager.shared.isPremium = isPremium
                
                if isPremium {
                    print("✅ Purchase successful!")
                    completion(.success(true))
                } else {
                    print("⚠️ Purchase completed but premium not active")
                    completion(.success(false))
                }
            }
        }
    }
    
    func restorePurchases(completion: @escaping (Result<Bool, Error>) -> Void) {
        isLoading = true
        
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("❌ Restore error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let isPremium = customerInfo?.entitlements[self.premiumEntitlementID]?.isActive == true
                self.isPremium = isPremium
                UserDefaultsManager.shared.isPremium = isPremium
                
                if isPremium {
                    print("✅ Purchases restored!")
                    completion(.success(true))
                } else {
                    print("ℹ️ No purchases to restore")
                    completion(.success(false))
                }
            }
        }
    }
}

// MARK: - PurchasesDelegate

extension RevenueCatService: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        let isPremium = customerInfo.entitlements[premiumEntitlementID]?.isActive == true
        
        DispatchQueue.main.async {
            self.isPremium = isPremium
            UserDefaultsManager.shared.isPremium = isPremium
            print("📱 Customer info updated - Premium: \(isPremium)")
        }
    }
}

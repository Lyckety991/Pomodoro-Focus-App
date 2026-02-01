//
//  SettingsViewModel.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation
import SwiftUI
internal import Combine

class SettingsViewModel: ObservableObject {
    @Published var focusDuration: Int
    @Published var shortBreakDuration: Int
    @Published var longBreakDuration: Int
    @Published var longBreakInterval: Int
    
    @Published var selectedSound: String
    @Published var soundVolume: Double
    @Published var notificationSound: Bool
    
    @Published var selectedTheme: String
    @Published var isPremium: Bool
    
    @Published var showPaywall = false
    @Published var showAbout = false
    
    private let userDefaults = UserDefaultsManager.shared
    private let revenueCat = RevenueCatService.shared
    
    init() {
        // Load from UserDefaults
        self.focusDuration = userDefaults.focusDuration
        self.shortBreakDuration = userDefaults.shortBreakDuration
        self.longBreakDuration = userDefaults.longBreakDuration
        self.longBreakInterval = userDefaults.longBreakInterval
        
        self.selectedSound = userDefaults.selectedSound
        self.soundVolume = userDefaults.soundVolume
        self.notificationSound = userDefaults.notificationSound
        
        self.selectedTheme = userDefaults.selectedTheme
        self.isPremium = userDefaults.isPremium
    }
    
    // MARK: - Save Methods
    
    func saveFocusDuration(_ value: Int) {
        focusDuration = value
        userDefaults.focusDuration = value
        print("✅ Focus duration saved: \(value) min")
    }
    
    func saveShortBreakDuration(_ value: Int) {
        shortBreakDuration = value
        userDefaults.shortBreakDuration = value
    }
    
    func saveLongBreakDuration(_ value: Int) {
        longBreakDuration = value
        userDefaults.longBreakDuration = value
    }
    
    func saveLongBreakInterval(_ value: Int) {
        longBreakInterval = value
        userDefaults.longBreakInterval = value
    }
    
    func saveSound(_ sound: String) {
        selectedSound = sound
        userDefaults.selectedSound = sound
        
        // Play preview
        if sound != "none" {
            AudioService.shared.playAmbientSound(sound)
            
            // Stop after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                AudioService.shared.stopAmbientSound()
            }
        }
    }
    
    func saveSoundVolume(_ volume: Double) {
        soundVolume = volume
        userDefaults.soundVolume = volume
        AudioService.shared.setVolume(volume)
    }
    
    func saveNotificationSound(_ enabled: Bool) {
        notificationSound = enabled
        userDefaults.notificationSound = enabled
    }
    
    func saveTheme(_ theme: String) {
        guard isPremium || theme == "default" else {
            showPaywall = true
            return
        }
        
        selectedTheme = theme
        userDefaults.selectedTheme = theme
    }
    
    // MARK: - Premium Actions
    
    func unlockPremium() {
        showPaywall = true
    }
    
    func restorePurchases() {
        revenueCat.restorePurchases { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let restored):
                    if restored {
                        self?.isPremium = true
                        print("✅ Purchases restored!")
                    } else {
                        print("❌ No purchases found")
                    }
                case .failure(let error):
                    print("❌ Restore failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Reset
    
    func resetToDefaults() {
        focusDuration = 25
        shortBreakDuration = 5
        longBreakDuration = 15
        longBreakInterval = 4
        
        userDefaults.focusDuration = 25
        userDefaults.shortBreakDuration = 5
        userDefaults.longBreakDuration = 15
        userDefaults.longBreakInterval = 4
    }
}


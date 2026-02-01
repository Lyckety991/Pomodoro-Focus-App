//
//  UserDefaultsManager.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}
    
    // Timer Settings
    @UserDefault(key: "focusDuration", defaultValue: 25)
    var focusDuration: Int
    
    @UserDefault(key: "shortBreakDuration", defaultValue: 5)
    var shortBreakDuration: Int
    
    @UserDefault(key: "longBreakDuration", defaultValue: 15)
    var longBreakDuration: Int
    
    @UserDefault(key: "longBreakInterval", defaultValue: 4)
    var longBreakInterval: Int
    
    // Audio Settings
    @UserDefault(key: "selectedSound", defaultValue: "none")
    var selectedSound: String
    
    @UserDefault(key: "soundVolume", defaultValue: 0.5)
    var soundVolume: Double
    
    @UserDefault(key: "notificationSound", defaultValue: true)
    var notificationSound: Bool
    
    // App Settings
    @UserDefault(key: "hasCompletedOnboarding", defaultValue: false)
    var hasCompletedOnboarding: Bool
    
    @UserDefault(key: "selectedTheme", defaultValue: "default")
    var selectedTheme: String
    
    // Premium
    @UserDefault(key: "isPremium", defaultValue: false)
    var isPremium: Bool
}

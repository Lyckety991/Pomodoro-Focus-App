//
//  ScreenWakeService.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 09.02.26.
//

import UIKit

class ScreenWakeService {
    static let shared = ScreenWakeService()
    
    private init() {}
    
    private var isKeepingAwake = false
    
    /// Verhindert dass der Screen ausgeht
    func keepScreenAwake() {
        guard !isKeepingAwake else { return }
        
        UIApplication.shared.isIdleTimerDisabled = true
        isKeepingAwake = true
        
        print("🔆 Screen will stay awake")
    }
    
    /// Erlaubt dem Screen wieder auszugehen
    func allowScreenSleep() {
        guard isKeepingAwake else { return }
        
        UIApplication.shared.isIdleTimerDisabled = false
        isKeepingAwake = false
        
        print("💤 Screen can sleep again")
    }
    
    /// Current status
    var isAwake: Bool {
        isKeepingAwake
    }
}

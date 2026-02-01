//
//  TimerMode.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation
import SwiftUI

enum TimerMode: String, Codable {
    case focus
    case shortBreak
    case longBreak
    
    var displayName: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
    
    var defaultDuration: Int {
        switch self {
        case .focus: return UserDefaultsManager.shared.focusDuration
        case .shortBreak: return UserDefaultsManager.shared.shortBreakDuration
        case .longBreak: return UserDefaultsManager.shared.longBreakDuration
        }
    }
    
    var color: Color {
        switch self {
        case .focus:
            return DesignSystem.shared.colors.focus
        case .shortBreak:
            return DesignSystem.shared.colors.shortBreak
        case .longBreak:
            return DesignSystem.shared.colors.longBreak
        }
    }
}

enum TimerState {
    case idle
    case running
    case paused
    case completed
}

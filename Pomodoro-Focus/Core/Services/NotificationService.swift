//
//  NotificationService.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation
import UserNotifications
internal import Combine

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func sendCompletionNotification(for mode: TimerMode) {
        let content = UNMutableNotificationContent()
        
        switch mode {
        case .focus:
            content.title = "Focus Session Complete! 🎉"
            content.body = "Great work! Time for a break."
        case .shortBreak:
            content.title = "Break's Over! ⏰"
            content.body = "Ready to focus again?"
        case .longBreak:
            content.title = "Long Break Complete! 🌟"
            content.body = "You've earned it. Back to focus?"
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
}

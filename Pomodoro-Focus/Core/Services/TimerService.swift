//
//  TimerService.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation
internal import Combine
import UIKit
internal import CoreData

class TimerService: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var timerState: TimerState = .idle
    @Published var currentMode: TimerMode = .focus
    @Published var sessionsCompleted: Int = 0
    
    private var timer: Timer?
    private var startTime: Date?
    private var totalDuration: Int = 0
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Timer Controls
    
    func start() {
        guard timerState != .running else { return }
        
        if timerState == .idle {
            setupNewSession()
        }
        
        timerState = .running
        startTime = Date()
        
        /// Shared Service um den Screen an zu behalten bei Nutzung des Timers
        
        if UserDefaultsManager.shared.keepScreenAwake{
            ScreenWakeService.shared.keepScreenAwake()
            
        }
        
        
        startBackgroundTask()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func pause() {
        guard timerState == .running else { return }
        
        timerState = .paused
        timer?.invalidate()
        timer = nil
        ///Wen der Timer beendet ist geht der Screen wieder aus.
        ScreenWakeService.shared.allowScreenSleep()
        
        endBackgroundTask()
    }
    
    func resume() {
        guard timerState == .paused else { return }
        start()
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        timerState = .idle
        timeRemaining = currentMode.defaultDuration * 60
        totalDuration = timeRemaining
        
        /// Bei Reset darf der Bildschrim sich wieder ausschalten.
        ScreenWakeService.shared.allowScreenSleep()
        
        endBackgroundTask()
    }
    
    func skip() {
        completeSession(completed: false)
        switchToNextMode()
    }
    
    // MARK: - Private Methods
    
    private func setupNewSession() {
        totalDuration = currentMode.defaultDuration * 60
        timeRemaining = totalDuration
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            sessionCompleted()
            return
        }
        
        timeRemaining -= 1
    }
    
    private func sessionCompleted() {
        timer?.invalidate()
        timer = nil
        timerState = .completed
        
        // Save to Core Data
        completeSession(completed: true)
        
        // Send notification
        NotificationService.shared.sendCompletionNotification(for: currentMode)
        
        // Play sound
        AudioService.shared.playCompletionSound()
        
        ScreenWakeService.shared.allowScreenSleep()
        
        endBackgroundTask()
        
        // Auto-switch to next mode after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.switchToNextMode()
        }
    }
    
    private func switchToNextMode() {
        switch currentMode {
        case .focus:
            sessionsCompleted += 1
            
            // Every 4th session is a long break
            if sessionsCompleted % UserDefaultsManager.shared.longBreakInterval == 0 {
                currentMode = .longBreak
            } else {
                currentMode = .shortBreak
            }
            
        case .shortBreak, .longBreak:
            currentMode = .focus
        }
        
        reset()
    }
    
    private func completeSession(completed: Bool) {
        let context = PersistenceController.shared.container.viewContext
        
        let session = FocusSession(context: context)
        session.id = UUID()
        session.startTime = startTime ?? Date()
        session.endTime = Date()
        session.duration = Int32(totalDuration - timeRemaining)
        session.timerMode = currentMode.rawValue
        session.completed = completed
        session.createdAt = Date()
        
        PersistenceController.shared.save()
    }
    
    // MARK: - Background Task
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    // MARK: - Computed Properties
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalDuration))
    }
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        ScreenWakeService.shared.allowScreenSleep()
    }
}

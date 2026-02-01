//
//  TimerViewModel.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation
import SwiftUI
internal import Combine

class TimerViewModel: ObservableObject {
    @Published var timerService = TimerService()
    @Published var showSettings = false
    @Published var showStatistics = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen to timer service changes
        timerService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    func toggleTimer() {
        switch timerService.timerState {
        case .idle, .completed:
            timerService.start()
        case .running:
            timerService.pause()
        case .paused:
            timerService.resume()
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func resetTimer() {
        timerService.reset()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func skipSession() {
        timerService.skip()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // MARK: - Computed Properties
    
    var buttonTitle: String {
        switch timerService.timerState {
        case .idle, .completed:
            return "Start"
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        }
    }
    
    var buttonIcon: String {
        switch timerService.timerState {
        case .idle, .completed:
            return "play.fill"
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
        }
    }
    
    var canReset: Bool {
        timerService.timerState != .idle
    }
    
    var currentModeColor: Color {
        Color(timerService.currentMode.color)
    }
}

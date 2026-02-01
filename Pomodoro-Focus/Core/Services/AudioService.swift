//
//  AudioService.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation
import AVFoundation
internal import Combine

class AudioService: ObservableObject {
    var objectWillChange: ObservableObjectPublisher = .init()
    
    static let shared = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    
    private init() {
        // All stored properties are initialized by this point.
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playCompletionSound() {
        guard UserDefaultsManager.shared.notificationSound else { return }
        
        // System sound for now
        AudioServicesPlaySystemSound(1057) // SMS received sound
    }
    
    func playAmbientSound(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        do {
            ambientPlayer = try AVAudioPlayer(contentsOf: url)
            ambientPlayer?.numberOfLoops = -1 // Loop indefinitely
            ambientPlayer?.volume = Float(UserDefaultsManager.shared.soundVolume)
            ambientPlayer?.play()
        } catch {
            print("Failed to play ambient sound: \(error)")
        }
    }
    
    func stopAmbientSound() {
        ambientPlayer?.stop()
        ambientPlayer = nil
    }
    
    func setVolume(_ volume: Double) {
        ambientPlayer?.volume = Float(volume)
    }
}

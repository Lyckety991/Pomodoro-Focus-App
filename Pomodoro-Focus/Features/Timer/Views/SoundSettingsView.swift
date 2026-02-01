//
//  SoundSettingsView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI

struct SoundSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    private let design = DesignSystem.shared
    
    // Available sounds (Free + Premium)
    private let sounds = [
        SoundOption(id: "none", name: "None", isPremium: false),
        SoundOption(id: "rain", name: "Rain", isPremium: false),
        SoundOption(id: "waves", name: "Ocean Waves", isPremium: false),
        SoundOption(id: "forest", name: "Forest", isPremium: true),
        SoundOption(id: "fire", name: "Fireplace", isPremium: true),
        SoundOption(id: "cafe", name: "Coffee Shop", isPremium: true),
        SoundOption(id: "whitenoise", name: "White Noise", isPremium: true),
    ]
    
    var body: some View {
        List {
            Section {
                ForEach(sounds) { sound in
                    SoundRow(
                        sound: sound,
                        isSelected: viewModel.selectedSound == sound.id,
                        isPremiumUser: viewModel.isPremium
                    ) {
                        if sound.isPremium && !viewModel.isPremium {
                            viewModel.unlockPremium()
                        } else {
                            viewModel.saveSound(sound.id)
                        }
                    }
                }
            } header: {
                Text("Ambient Sounds")
            } footer: {
                Text("Play background sounds during focus sessions")
            }
            
            if viewModel.selectedSound != "none" {
                Section {
                    VStack(alignment: .leading, spacing: design.spacing.sm) {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(design.colors.textSecondary)
                            
                            Text("Volume")
                                .font(design.typography.body)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.soundVolume * 100))%")
                                .font(design.typography.caption)
                                .foregroundColor(design.colors.textSecondary)
                        }
                        
                        Slider(value: $viewModel.soundVolume, in: 0...1)
                            .tint(design.colors.primary)
                            .onChange(of: viewModel.soundVolume) { newValue in
                                viewModel.saveSoundVolume(newValue)
                            }
                    }
                    .padding(.vertical, design.spacing.sm)
                }
            }
        }
        .navigationTitle("Sounds & Audio")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sound Option Model

struct SoundOption: Identifiable {
    let id: String
    let name: String
    let isPremium: Bool
}

// MARK: - Sound Row Component

struct SoundRow: View {
    let sound: SoundOption
    let isSelected: Bool
    let isPremiumUser: Bool
    let onTap: () -> Void
    
    private let design = DesignSystem.shared
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: soundIcon)
                    .foregroundColor(isSelected ? design.colors.primary : design.colors.textSecondary)
                    .frame(width: 30)
                
                Text(sound.name)
                    .font(design.typography.body)
                    .foregroundColor(design.colors.textPrimary)
                
                Spacer()
                
                if sound.isPremium && !isPremiumUser {
                    PremiumBadge()
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(design.colors.primary)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
    }
    
    private var soundIcon: String {
        switch sound.id {
        case "rain": return "cloud.rain.fill"
        case "waves": return "water.waves"
        case "forest": return "leaf.fill"
        case "fire": return "flame.fill"
        case "cafe": return "cup.and.saucer.fill"
        case "whitenoise": return "waveform"
        default: return "speaker.slash.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        SoundSettingsView(viewModel: SettingsViewModel())
    }
}

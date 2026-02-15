//
//  Pomodoro_FocusApp.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI
internal import CoreData

@main
struct Pomodoro_FocusApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        // Configure RevenueCat on app launch
        RevenueCatService.shared.configure()
        
        // Request notification permissions
        NotificationService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                TimerView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                print("📱 App went to background")
                // Screen wake wird automatisch deaktiviert
                
            case .inactive:
                print("📱 App became inactive")
                
            case .active:
                print("📱 App became active")
                // Timer Service reaktiviert Screen Wake automatisch wenn running
                
            @unknown default:
                break
            }
        }
    }
}

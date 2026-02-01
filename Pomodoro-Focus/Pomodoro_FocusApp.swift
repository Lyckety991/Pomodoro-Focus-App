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
    }
}

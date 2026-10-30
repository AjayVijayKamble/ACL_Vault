//
//  ACLVaultApp.swift
//  ACLVault
//
//  AI-Powered iOS Knee Rehab & Range of Motion Tracker
//  Swift 6, SwiftUI, SwiftData (iOS 17.0+)
//

import SwiftUI
import SwiftData

@main
@MainActor
struct ACLVaultApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                UserProfile.self,
                ROMMeasurement.self,
                DailyCheckIn.self,
                Exercise.self,
                WorkoutSessionLog.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = modelContainer
            
            // Seed 10 levels, 30+ exercises & 30-day realistic progression on first launch
            ProtocolSeeder.seedInitialDataIfNeeded(context: modelContainer.mainContext)
            
            // Prepare haptics
            HapticManager.prepare()
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}


//
//  KinetiqApp.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 15/04/26.
//

import SwiftUI

@main
struct KinetiqApp: App {
    @AppStorage("HasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                DashboardView()
            } else {
                OnboardingView()
            }
        }
    }
}

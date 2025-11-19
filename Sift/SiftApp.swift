//
//  SiftApp.swift
//  Sift
//
//  Created by Saket Gahlot on 11/9/25.
//

import SwiftUI

@main
struct SiftApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}

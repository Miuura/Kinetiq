//
//  OnboardingPage1View.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import SwiftUI

struct OnboardingPage1View: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("EVOLUTION OF SCREEN TIME")
                .font(.caption)
                .fontWeight(.regular)
                .kerning(4.0)
                .foregroundColor(AppTheme.accent)
                .padding(.top, 16)
            
            Text("Break the Cycle")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryText)
            
            Text("Stop doomscrolling and reclaim your time. Kinetiq helps you turn mindless screen time into healthy, active breaks.")
                .font(.body)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineSpacing(4)
            
            Spacer()
        }
        .background(
            Image("Onboarding1") // Pastikan aset Anda
                .resizable()
                .scaledToFill()
                .frame(width: 537, height: 874)
                .clipped()
                .offset(y: 200),
            alignment: .bottom
        )
    }
}

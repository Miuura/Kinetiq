//
//  OnboardingPage2View.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import SwiftUI

struct OnboardingPage2View: View {
    var body: some View {
        VStack(spacing: 24) {
            // Teks dengan warna campuran
            // Menggunakan interpolasi Text untuk style yang berbeda
            Text("Lock. Walk.\n\(Text("Unlock.").foregroundColor(AppTheme.accent))")
                .foregroundColor(AppTheme.primaryText)
                .font(.largeTitle)
                .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.top, 16)
            
            Text("Set a daily time limit for your most distracting apps. Once your time is up, they lock automatically. The only way to unlock them? Hit your step goal!")
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineSpacing(4)
                .fontWeight(.regular)
            
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.0))
                    .frame(height: 300)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .background(
            Image("Onboarding2")
                .resizable()
                .scaledToFill()
                .frame(width: 522, height: 551)
                .clipped()
                .offset(y: -50),
            alignment: .bottom
        )

    }
}

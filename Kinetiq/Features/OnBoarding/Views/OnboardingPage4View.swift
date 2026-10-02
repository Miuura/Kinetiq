//
//  OnboardingPage4View.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import SwiftUI

struct OnboardingPage4View: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    // Warna untuk background card agar sedikit kontras dari background utama
    let cardBackground = Color.white.opacity(0.08)
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Header Area
            VStack(spacing: 12) {
                Text("Tailored For You")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primaryText)
                
                Text("Based on the latest neuroscience, we've set up a healthy baseline to beat brainrot.")
                    .font(.body)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // 2. Sliders Area
            VStack(spacing: 20) {
                // Custom Card 1: Daily Screen Limit
                SettingSliderCard(
                    warna: "DAE1FF",
                    icon: "clock",
                    warnaIcon: "0050CB",
                    title: "Daily Screen Limit",
                    value: $viewModel.dailyScreenLimit,
                    range: 60...240,
                    step: 15,
                    unit: "min",
                    backgroundColor: cardBackground,
                    description: "Batas total main per hari."
                )
                
                // Custom Card 2: Session Limit
                SettingSliderCard(
                    warna: "FFDBD0",
                    icon: "hourglass",
                    warnaIcon: "A33200",
                    title: "Session Limit",
                    value: $viewModel.sessionLimit,
                    range: 5...60,
                    step: 5,
                    unit: "min",
                    backgroundColor: cardBackground,
                    description: "Durasi per sesi sebelum lock."
                )
                
                // Custom Card 3: Step Goal
                SettingSliderCard(
                    warna: "DAE1FF",
                    icon: "figure.run",
                    warnaIcon: "425CA0",
                    title: "Unlock Your Goal",
                    value: $viewModel.stepGoal,
                    range: 100...3000,
                    step: 100,
                    unit: "steps",
                    backgroundColor: cardBackground,
                    description: "Step untuk unlock sesi."
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // 3. Final Button
            Button(action: {
                viewModel.saveUserDataAndFinish()
            }) {
                Text("Let's Get Started")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#363636")) // Warna abu-abu sesuai desain Anda
                    .cornerRadius(28)
            }
            .padding(.horizontal, 24)
            // Memastikan tombol ini sejajar dengan tinggi tombol "Next" di halaman lain
            .padding(.bottom, 40)
        }
        // KUNCI: Saat halaman 4 muncul, tarik data default dari Persona yang dipilih di halaman 3!
        .onAppear {
            viewModel.loadDefaultsFromSelectedPersona()
        }
    }
}

// MARK: - Reusable Slider Component
struct SettingSliderCard: View {
    let warna: String
    let icon: String
    let warnaIcon: String
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let backgroundColor: Color
    let description: String?

    init(
        warna: String,
        icon: String,
        warnaIcon: String,
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        unit: String,
        backgroundColor: Color,
        description: String? = nil
    ) {
        self.warna = warna
        self.icon = icon
        self.warnaIcon = warnaIcon
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.unit = unit
        self.backgroundColor = backgroundColor
        self.description = description
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header: Icon + Title + Value Text
            HStack(alignment: .top, spacing: 12) {
                // Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: warna)) // Atau sesuaikan dengan warna pastel/aksen
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: warnaIcon))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .layoutPriority(1)

                    if let description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText.opacity(0.88))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }

                Spacer()

                Text("\(Int(value)) \(unit)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primaryText)
            }
            
            // Native Slider
            Slider(value: $value, in: range, step: step)
                .tint(AppTheme.accent) // Mengubah warna track aktif menjadi biru (#64A1FF)

        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(backgroundColor)
        .cornerRadius(24)
    }
}

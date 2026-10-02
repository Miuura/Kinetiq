//
//  OnboardingPage3View.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import SwiftUI

struct OnboardingPage3View: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    // 1. Lebar Kartu (Gunakan 0.68 atau 68% agar sisa layar di kiri-kanan lebih besar untuk kartu sebelahnya)
    let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.63
    
    // 2. Tinggi Kartu (Kalikan dengan 1.45 atau 1.5 agar kartu lebih panjang ke bawah)
    let cardHeight: CGFloat = (UIScreen.main.bounds.width * 0.68) * 1.48
    
    // 3. Jarak Antar Kartu (Kecilkan angka ini jika ingin kartu sebelahnya lebih menempel)
    let cardSpacing: CGFloat = 14
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text("Who Are You?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryText)
                .padding(.top, 32)
            
            Text("Kinetiq adapts to your lifestyle. Pick the profile that best matches your daily rhythm to optimize your focus goals.")
                .font(.body)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 16)
                .lineSpacing(4)
            
            Spacer()
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(viewModel.personas) { persona in
                        
                        Image(persona.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: cardHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 10)
                            
                            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                    .opacity(phase.isIdentity ? 1.0 : 0.5)
                            }
                            .offset(y: -40)
//                            .shadow(
//                                color: Color(hex: "7FAFFF").opacity(0.1),
//                                radius: 8,
//                                x: -20,
//                                y: 30
//                            )
                    }
                }
                .scrollTargetLayout()
            }
            .frame(height: cardHeight * 1.25)
            
            .contentMargins(.horizontal, (UIScreen.main.bounds.width - cardWidth) / 2, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $viewModel.selectedPersonaID)
            
            Spacer()
            Spacer()
        }
    }
}

//
//  OnboardingView.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Page Indicator (Dots)
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.totalPages, id: \.self) { index in
                        Circle()
                            .fill(viewModel.currentPageIndex == index ? AppTheme.primaryText : AppTheme.secondaryText.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // 2. TAB VIEW (Tanpa ForEach)
                // Di dalam OnboardingView.swift
                TabView(selection: $viewModel.currentPageIndex) {
                    
                    OnboardingPage1View()
                        .tag(0)
                    
                    OnboardingPage2View()
                        .tag(1)
                    
                    // Passing viewModel ke Page 3
                    OnboardingPage3View(viewModel: viewModel)
                        .tag(2)
                    
                    OnboardingPage4View(viewModel: viewModel)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))            }
            .ignoresSafeArea(edges: .bottom)
            
            // 3. Navigation Buttons (Tetap sama seperti sebelumnya)
            if !viewModel.isLastPage {
                VStack {
                    Spacer()
                    HStack {
                        if viewModel.currentPageIndex > 0 {
                            Button(action: { viewModel.previousPage() }) {
                                Text("Back")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.primaryText)
                                    .frame(width: 90, height: 50)
                                    .background(Color(hex: "#363636"))
                                    .cornerRadius(25)
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        Button(action: { viewModel.nextPage() }) {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.primaryText)
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}

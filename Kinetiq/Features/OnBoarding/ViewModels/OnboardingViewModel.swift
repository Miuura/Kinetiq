//
//  OnboardingViewModel.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0
    let totalPages: Int = 4
    
    // --- TAMBAHAN BARU UNTUK PAGE 3 (iOS 17 Carousel) ---
    // Dimensi layar dasar (pt) untuk kalkulasi
    @Published var screenWidth: CGFloat = UIScreen.main.bounds.width
    @Published var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    // Menyimpan ID persona yang sedang ada di tengah layar
    @Published var selectedPersonaID: UUID?
    
    // Data persona hanya berisi nama aset
    @Published var personas: [UserPersona] = [
        UserPersona(imageName: "Onboarding3-1", defaultScreenLimit: 120, defaultSessionLimit: 30, defaultStepGoal: 1000),
        UserPersona(imageName: "Onboarding3-2", defaultScreenLimit: 180, defaultSessionLimit: 60, defaultStepGoal: 300), 
        UserPersona(imageName: "Onboarding3-3", defaultScreenLimit: 210, defaultSessionLimit: 45, defaultStepGoal: 500)
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set default yang aktif di awal ke persona index ke-1 (misal gambar tengah)
        selectedPersonaID = personas[0].id
        
        // Mulai mendengarkan rotasi layar
        setupRotationObserver()
    }
    
    // Fungsi untuk mendeteksi rotasi layar dan memperbarui ukuran dasar
    private func setupRotationObserver() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                // Memaksa UI memperbarui ukuran dasar
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.screenWidth = UIScreen.main.bounds.width
                    self.screenHeight = UIScreen.main.bounds.height
                }
            }
            .store(in: &cancellables)
    }
    
    @Published var dailyScreenLimit: Double = 60
        @Published var sessionLimit: Double = 15
        @Published var stepGoal: Double = 500
    
    var isLastPage: Bool {
            currentPageIndex == totalPages - 1
        }
    
    func loadDefaultsFromSelectedPersona() {
            if let persona = personas.first(where: { $0.id == selectedPersonaID }) {
                dailyScreenLimit = Double(persona.defaultScreenLimit)
                sessionLimit = Double(persona.defaultSessionLimit)
                stepGoal = Double(persona.defaultStepGoal)
            }
        }
    
    func saveUserDataAndFinish() {
            // Simpan data ke UserDefaults
            UserDefaults.standard.set(dailyScreenLimit, forKey: "DailyScreenLimit")
            UserDefaults.standard.set(sessionLimit, forKey: "SessionLimit")
            UserDefaults.standard.set(stepGoal, forKey: "StepGoal")
            
            // Ubah flag onboarding selesai (Nanti diakses di ContentView)
            UserDefaults.standard.set(true, forKey: "HasSeenOnboarding")
            
            print("Data Tersimpan! Screen: \(dailyScreenLimit)m, Session: \(sessionLimit)m, Steps: \(stepGoal)")
        }
    
    // --- Logika Halaman (Tetap sama) ---
    func nextPage() {
        if currentPageIndex < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPageIndex += 1
            }
        } else {
            print("Onboarding Finished!")
        }
    }
    
    func previousPage() {
        if currentPageIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPageIndex -= 1
            }
        }
    }
}

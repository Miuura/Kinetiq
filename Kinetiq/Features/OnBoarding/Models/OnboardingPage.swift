//
//  OnboardingPage.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let superTitle: String
    let title: String
    let description: String
    let imageName: String
    // Tambahan baru untuk support ukuran & posisi dinamis per halaman
    let imageSize: CGSize
    let imageOffset: CGFloat
}


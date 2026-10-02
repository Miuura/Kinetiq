//
//  UserPersona.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

// Models/UserPersona.swift
import Foundation

struct UserPersona: Identifiable, Hashable {
    let id = UUID()
    let imageName: String // HANYA menyimpan nama aset gambar
    
    // Parameter yang akan diteruskan ke Page 4
    let defaultScreenLimit: Int // dalam menit
    let defaultSessionLimit: Int // dalam menit
    let defaultStepGoal: Int
}

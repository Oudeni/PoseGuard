//
//  DayData.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
import UIKit

struct DayData: Identifiable, Equatable {
    let id = UUID()
    let day: String
    let sessions: [PostureSession]
    
    // Ore raggruppate per categoria
    var buonaHours: Double {
        sessions.filter { $0.category == .buona }.reduce(0) { $0 + $1.duration }
    }
    
    var mediaHours: Double {
        sessions.filter { $0.category == .media }.reduce(0) { $0 + $1.duration }
    }
    
    var cattiveHours: Double {
        sessions.filter { $0.category == .cattiva }.reduce(0) { $0 + $1.duration }
    }
    
    // Statistiche giornaliere
    var totalHours: Double {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var averageQuality: Double {
        let weightedSum = sessions.reduce(0) { $0 + (Double($1.avgQuality) * $1.duration) }
        return sessions.isEmpty ? 0 : weightedSum / totalHours
    }
    
    // Implementazione di Equatable
    static func == (lhs: DayData, rhs: DayData) -> Bool {
        lhs.id == rhs.id && lhs.day == rhs.day
    }
}

// Estensione per convertire codici esadecimali in Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}



//
//  Posturesession.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
import UIKit
import Charts

struct PostureSession: Identifiable, Equatable {
    let id = UUID()
    let startTime: String
    let endTime: String
    let duration: Double
    let avgQuality: Int
    let category: PostureCategory
    
    // Implementazione di Equatable
    static func == (lhs: PostureSession, rhs: PostureSession) -> Bool {
        lhs.id == rhs.id
    }
}

enum PostureCategory: String, CaseIterable, Identifiable {
    case buona = "Good"
    case media = "Medium"
    case cattiva = "Bad"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .buona: return Color(hex: "4CEF7E") // Verde brillante
        case .media: return Color(hex: "FFD700") // Giallo oro
        case .cattiva: return Color(hex: "FF5252") // Rosso
        }
    }
    
    var icon: String {
        switch self {
        case .buona: return "checkmark.circle.fill"
        case .media: return "exclamationmark.circle.fill"
        case .cattiva: return "xmark.circle.fill"
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CustomRoundedCornerShape(radius: radius, corners: corners))
    }
}

struct CustomRoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

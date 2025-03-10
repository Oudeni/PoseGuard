//
//  ReportTypeSelector.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Report Type Selector
enum ReportType: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
}

// MARK: - ReportTypeSelector Component
struct ReportTypeSelector: View {
    @Binding var selectedType: ReportType
    let accentColor: Color
    let textColor: Color
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ReportType.allCases, id: \.self) { type in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedType = type
                    }
                    // Aggiunge feedback aptico
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Text(type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(selectedType == type ? textColor : textColor.opacity(0.6))
                .background(
                    ZStack {
                        if selectedType == type {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(accentColor.opacity(0.3))
                                .matchedGeometryEffect(id: "TAB_BACKGROUND", in: namespace)
                        }
                    }
                )
            }
        }
        .padding(4)
        .background(backgroundColor.opacity(0.3))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    @Namespace private var namespace
}

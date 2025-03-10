//
//  StatView.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
// MARK: - StatView and Components
struct StatView: View {
    let title: String
    let value: String
    let icon: String
    let accentColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 16))
            
            Text(value)
                .font(.headline)
                .foregroundColor(textColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(secondaryTextColor)
        }
    }
}

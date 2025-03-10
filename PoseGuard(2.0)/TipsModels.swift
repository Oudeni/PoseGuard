//
//  TipsModels.swift
//  PoseGuard(2.0)
//
//  Created by Acri Stefano on 09/03/25.
//

import Foundation
import SwiftUI

// MARK: - Model
struct PostureTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let timestamp: Date
    
    // Formatted time string
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
}

// MARK: - ViewModel
class TipsViewModel: ObservableObject {
    @Published var tips: [PostureTip] = []
    
    init() {
        loadDemoTips()
    }
    
    func loadDemoTips() {
        let now = Date()
        
        tips = [
            PostureTip(
                title: "Keep your shoulders back!",
                description: "Avoid slouching and gently roll your shoulders back to open up your chest.",
                timestamp: now
            ),
            PostureTip(
                title: "Engage your core!",
                description: "Strengthening your core muscles helps support your spine and improves posture.",
                timestamp: now
            ),
            PostureTip(
                title: "Keep your feet flat on the ground!",
                description: "When sitting, make sure your feet are fully supported and not dangling.",
                timestamp: now
            ),
            PostureTip(
                title: "Align your ears with your shoulders!",
                description: "Avoid leaning your head forward; keep your head aligned with your spine.",
                timestamp: now
            ),
            PostureTip(
                title: "Take breaks regularly!",
                description: "Stand up, stretch, and move around every 30-60 minutes to relieve tension.",
                timestamp: now
            ),
            PostureTip(
                title: "Adjust your screen height!",
                description: "Ensure your screen is at eye level to prevent neck strain.",
                timestamp: now
            )
        ]
    }
}

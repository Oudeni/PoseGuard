//
//  PoseGuard_2_0_App.swift
//  PoseGuard(2.0)
//
//  Created by Acri Stefano on 07/03/25.
//

import SwiftUI

@main
struct TrackingAppApp: App {
    init() {
        
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

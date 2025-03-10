//
//  PoseGuard__3_0_App.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
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

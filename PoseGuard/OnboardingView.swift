//
//  OnboardingView.swift
//  PoseGuard
//
//  Created by Acri Stefano on 06/03/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var navigateToTrackingView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Spacer()
                    
                    Text("What's\nPoseGuard")
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                    
                    InstructionRow(
                        icon: "airpodspro",
                        title: "Connect your airpods",
                        description: "Make sure you have connected your AirPods to your device."
                    )
                    
                    InstructionRow(
                        icon: "hand.tap",
                        title: "Tap to start tracking",
                        description: "When the main button goes green the app is tracking your posture."
                    )
                    
                    InstructionRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Check your report",
                        description: "Remember to check your daily report to visualize your progress."
                    )
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        ProfileButton()
                        
                        Text("Remember this app is always working on background, to ensure the privacy of your data remember to check the user's data manual in the learn more section. We will not share your posture's data")
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Button("See how your data is managed...") {
                            // Action
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                    }
                    
                    Button(action: {
                        navigateToTrackingView = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(
                        NavigationLink(destination: TrackingView().navigationBarHidden(true), isActive: $navigateToTrackingView) {
                            EmptyView()
                        }
                        .opacity(0)
                    )
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InstructionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.green)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ProfileButton: View {
    var body: some View {
        Button(action: {
            // Profile action
        }) {
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.green)
                
                Image(systemName: "person.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
            }
        }
    }
}

#Preview {
    OnboardingView()
}

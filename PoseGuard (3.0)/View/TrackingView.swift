import Foundation
import SwiftUI
import CoreMotion
import UserNotifications

struct TrackingView: View {
    @State private var showTips = false
    @State private var isTracking = false
    @State private var pulseAnimation = false
    @State private var waveAnimation = false
    @State private var rotationAnimation = false
    @State private var showReport = false
    @State private var panOffset: CGFloat = 0
    @State private var previousPanOffset: CGFloat = 0
    
    // For sound wave animation
    let waveCount = 5
    
    // Add PostureMonitorModel instance
    @StateObject private var postureMonitor = PostureMonitorModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Animated background waves when tracking (similar to Shazam's listening animation)
            if isTracking {
                ZStack {
                    // Multiple expanding circles
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(postureMonitor.isPostureCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 2)
                            .scaleEffect(pulseAnimation ? 2 + CGFloat(index) * 0.4 : 0.2)
                            .opacity(pulseAnimation ? 0 : 0.7)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.5),
                                value: pulseAnimation
                            )
                    }
                    
                    // Sound wave animation (vertical bars)
                    HStack(spacing: 8) {
                        ForEach(0..<waveCount, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(postureMonitor.isPostureCorrect ? Color.green.opacity(0.7) : Color.red.opacity(0.7))
                                .frame(width: 6, height: waveAnimation ? 40 + CGFloat(Int.random(in: 10...60)) : 5)
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.1),
                                    value: waveAnimation
                                )
                        }
                    }
                }
            }
            
            VStack {
                // Top toolbar
                HStack {
                
                    Text("PoseGuard")
                        .font(.system(size:24, weight: .medium))
                        .foregroundColor(.gray)
                        .transition(.opacity)
                    
                    
                    Spacer()
                    
                    Button(action: {
                            showTips = true
                        }) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                        .frame(width: 50, height: 50)
                                )
                        }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Status text with animated reveal
                Text(isTracking ? postureMonitor.postureMessage : "Tap to Track")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isTracking ? (postureMonitor.isPostureCorrect ? .green : .red) : .gray)
                    .padding(.bottom, 20)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: isTracking)
                    .animation(.easeInOut(duration: 0.5), value: postureMonitor.isPostureCorrect)
                
                // Main circle button with advanced animations
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTracking.toggle()
                    }
                    
                    // Start all animations when tracking begins
                    if isTracking {
                        withAnimation {
                            pulseAnimation = true
                            waveAnimation = true
                            rotationAnimation = true
                        }
                        postureMonitor.startMonitoring()
                    } else {
                        withAnimation {
                            pulseAnimation = false
                            waveAnimation = false
                            rotationAnimation = false
                        }
                        postureMonitor.stopMonitoring()
                    }
                }) {
                    ZStack {
                        // Animated outer glow
                        if isTracking {
                            Circle()
                                .stroke(postureMonitor.isPostureCorrect ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 3)
                                .frame(width: 170, height: 170)
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                        
                        // Main button background
                        Circle()
                            .fill(
                                isTracking ?
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        postureMonitor.isPostureCorrect ? Color.green : Color.red,
                                        postureMonitor.isPostureCorrect ? Color.green.opacity(0.7) : Color.red.opacity(0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150, height: 150)
                            .shadow(color: isTracking ? (postureMonitor.isPostureCorrect ? Color.green.opacity(0.7) : Color.red.opacity(0.7)) : Color.black.opacity(0.3), radius: 15)
                        
                        // Optional glowing effect
                        if isTracking {
                            Circle()
                                .fill(postureMonitor.isPostureCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                .frame(width: 150, height: 150)
                                .blur(radius: 5)
                        }
                        
                        // Icon with rotation animation
                        Image(systemName: "airpodspro")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .rotationEffect(Angle(degrees: rotationAnimation ? 360 : 0))
                            .animation(
                                isTracking ?
                                Animation.linear(duration: 10).repeatForever(autoreverses: false) :
                                .default,
                                value: rotationAnimation
                            )
                    }
                }
                .padding(.bottom, 40)
                .scaleEffect(isTracking ? 1.05 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isTracking)
                
                Spacer()
                
               
                // Bottom report bar with enhanced design and animations - now with drag gesture
                VStack {
                    // Drag indicator with subtle pulse
                    Rectangle()
                        .frame(width: 60, height: 5)
                        .cornerRadius(2.5)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 10)
                        .scaleEffect(x: isTracking ? 1.2 : 1.0, y: 1.0)
                        .animation(
                            isTracking ?
                            Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
                            .default,
                            value: isTracking
                        )
                    
                    HStack {
                        Text("My Report")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                        
                        Spacer()
                        
                        if isTracking {
                            // Animated time counter (similar to Shazam)
                            HStack(spacing: 2) {
                                Image(systemName: "timer")
                                    .foregroundColor(.green)
                                
                                TimeCounter()
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing)
                            .transition(.opacity)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedCornerShape(radius: 25, corners: [.topLeft, .topRight])
                        .fill(Color(UIColor.darkGray).opacity(0.6))
                        .edgesIgnoringSafeArea(.bottom)
                )
                .overlay(
                    // Add subtle reveal animation for the report panel
                    RoundedCornerShape(radius: 25, corners: [.topLeft, .topRight])
                        .stroke(isTracking ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                        .edgesIgnoringSafeArea(.bottom)
                )
                .gesture(
                    // Add pan gesture to detect swipe up to open report
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.height
                            panOffset = translation
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.height
                            // If swiped up with enough velocity, show the report
                            if velocity < -50 || value.translation.height < -20 {
                                showReport = true
                            }
                            panOffset = 0
                        }
                )
            }
            
            // Report view overlay
            MyReportView(isShowing: $showReport)
            MyTipsView(isShowing: $showTips)
        }
        .onAppear {
            // Request notification permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
            
            // Ensure animations start properly when view appears if tracking is already on
            if isTracking {
                pulseAnimation = true
                waveAnimation = true
                rotationAnimation = true
                postureMonitor.startMonitoring()
            }
        }
    }
}

// Time counter component (like Shazam's timer during listening)
struct TimeCounter: View {
    @State private var seconds = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(timeString)
            .font(.system(size: 16, weight: .medium))
            .monospacedDigit()
            .onReceive(timer) { _ in
                seconds += 1
            }
    }
    
    var timeString: String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%01d:%02d", minutes, remainingSeconds)
    }
}

// Custom Shape for specific corner radius
struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    // Custom function name to avoid redeclaration conflict with SwiftUI's built-in cornerRadius
    func cornerRadiusForSpecificCorners(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

#Preview {
    TrackingView()
}

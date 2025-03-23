import Foundation
import SwiftUI
import CoreMotion
import UserNotifications
import AVFoundation

struct TrackingView: View {
    @State private var showTips = false
    @State private var isTracking = false
    @State private var pulseAnimation = false
    @State private var waveAnimation = false
    @State private var rotationAnimation = false
    @State private var showReport = false
    @State private var showAirPodsAlert = false
    @State private var motionManager = CMHeadphoneMotionManager()
    @State private var panOffset: CGFloat = 0
    @State private var previousPanOffset: CGFloat = 0
    
    @Binding var hasCompletedOnboarding: Bool
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
                            .padding(.bottom, -45)
                    }
                    /*
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
                    }*/
                }
            }
            
            VStack {
                // Top toolbar
                HStack {
                    Button(action: {
                        hasCompletedOnboarding = false
                    }) {
                        Text("PoseGuard")
                            .font(.system(size:24, weight: .medium))
                            .foregroundColor(.gray)
                            .transition(.opacity)
                        
                    }
                    
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
                    .padding(.bottom, 50)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: isTracking)
                    .animation(.easeInOut(duration: 0.5), value: postureMonitor.isPostureCorrect)
                    .multilineTextAlignment(.center)
                
                // Main circle button with advanced animations
                Button(action: {
                    if !isTracking {  // Controlla se stiamo per attivare il tracciamento
                        areAirPodsConnected { isAirPods in
                            if isAirPods && motionManager.isDeviceMotionAvailable {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isTracking = true  // Imposta direttamente su true invece di toggle
                                }
                                
                                    // Avvia tutte le animazioni quando inizia il tracciamento
                                withAnimation {
                                    pulseAnimation = true
                                    waveAnimation = true
                                    rotationAnimation = true
                                }
                                postureMonitor.startMonitoring()
                            } else {
                                showAirPodsAlert = true
                            }
                        }
                    } else {  // Se stiamo disattivando il tracciamento, non serve verificare gli AirPods
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isTracking = false  // Imposta direttamente su false
                        }
                        
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
                .padding(.bottom, 100)
                .scaleEffect(isTracking ? 1.05 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isTracking)
                .alert("AirPods not connected", isPresented: $showAirPodsAlert) {
                    Button("OK", role: .cancel) {}
                }
                Spacer()
                
               /*
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
                .offset(y: showReport ? 120 : 1 + panOffset) // Effetto sheet
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.height
                            if translation > 0 || showReport { // Blocca il trascinamento verso il basso se è già chiuso
                                panOffset = translation
                            }
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.height
                            if velocity < -50 || value.translation.height < -100 {
                                showReport = true
                            } else if value.translation.height > 50 {
                                showReport = false
                            }
                            panOffset = 0
                        }
                )
                .animation(.spring(), value: showReport)
                */
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
    
    func areAirPodsConnected(completion: @escaping (Bool) -> Void) {
        let motionManager = CMHeadphoneMotionManager()
        
            // Verifica se il dispositivo supporta HeadphoneMotion
        guard motionManager.isDeviceMotionAvailable else {
            print("Il giroscopio non è disponibile.")
            completion(false)
            return
        }
        
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs
        
            // Verifica se ci sono cuffie Bluetooth collegate
        let areHeadphonesConnected = outputs.contains { output in
            output.portType == .bluetoothA2DP || output.portType == .bluetoothHFP
        }
        
        if !areHeadphonesConnected {
            print("Nessuna cuffia Bluetooth collegata.")
            completion(false)
            return
        }
        
            // Impostiamo un timeout per verificare se riceviamo dati dal giroscopio
        var receivedMotionData = false
        var timeoutTimer: Timer?
        
            // Inizia a monitorare i dati del giroscopio
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            if error != nil {
                    // In caso di errore, non sono AirPods con giroscopio
                timeoutTimer?.invalidate()
                motionManager.stopDeviceMotionUpdates()
                if !receivedMotionData {
                    print("Errore dal giroscopio - non sono AirPods.")
                    receivedMotionData = true
                    completion(false)
                }
                return
            }
            
            if data != nil && !receivedMotionData {
                    // Abbiamo ricevuto dati dal giroscopio, sono AirPods
                timeoutTimer?.invalidate()
                print("Giroscopio attivo e dati disponibili - sono AirPods.")
                receivedMotionData = true
                completion(true)
                    // Non fermiamo gli aggiornamenti in caso serva continuare a usare i dati
            }
        }
        
            // Impostiamo un timeout (ad esempio 1 secondo)
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            if !receivedMotionData {
                print("Timeout: nessun dato dal giroscopio - non sono AirPods.")
                motionManager.stopDeviceMotionUpdates()
                completion(false)
            }
        }
    }
    
}

// Time counter component (like Shazam's timer during listening)
struct TimeCounter: View {
    @StateObject private var viewModel = TimeCounterViewModel()
    
    var body: some View {
        Text(timeString)
            .font(.system(size: 16, weight: .medium))
            .monospacedDigit()
    }
    
    var timeString: String {
        let minutes = viewModel.seconds / 60
        let remainingSeconds = viewModel.seconds % 60
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
    struct PreviewWrapper: View {
        @State private var hasCompletedOnboarding = true
        
        var body: some View {
            TrackingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
    
    return PreviewWrapper()
}

//
//  P.swift
//  PoseGuard (3.0)
//
//  Created by Matteo Cotena on 11/03/25.
//

import SwiftUI
import CoreMotion
import UserNotifications

class PostureMonitorModel: ObservableObject {
    private let motionManager = CMHeadphoneMotionManager()
    private let queue = OperationQueue()
    private let thresholdAngle: Double = 15.0 // Threshold in degrees
    private var lastNotificationTime: Date?
    private var timer: Double = 5 //Notification timer
    
    @Published var isPostureCorrect: Bool = true
    @Published var postureMessage: String = NSLocalizedString("Correct Posture!", comment: "")
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var isMonitoring: Bool = false
    
    init() {
        checkAvailability()
        setupNotifications()
    }
    
    func checkAvailability() {
        if motionManager.isDeviceMotionAvailable {
            print("AirPods tracking available")
        } else {
            postureMessage = NSLocalizedString("AirPods not detected or not supported", comment: "")
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Authorized notifications")
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else {
            postureMessage = NSLocalizedString("AirPods not detected or not supported", comment: "")
            sendNotification(title: "PoseGuard", message: "AirPods not detected or not supported")
            return
        }
        
        isMonitoring = true
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else {
                DispatchQueue.main.async {
                    self?.postureMessage = NSLocalizedString("Error: \(error?.localizedDescription ?? "Unknown")", comment: "")
                    self?.sendNotification(title: "PoseGuard", message: "Tracking error")
                }
                return
            }
            
            self.checkPosture(motion: motion)
        }
    }
    
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
    }
    
    private func checkPosture(motion: CMDeviceMotion) {
        let roll = motion.attitude.roll * (180.0 / .pi)  // Convert to degrees
        let pitch = motion.attitude.pitch * (180.0 / .pi)  // Convert to degrees
        
        DispatchQueue.main.async {
            self.roll = roll
            self.pitch = pitch
            
            let wasPostureCorrect = self.isPostureCorrect
            let now = Date()
            
            if abs(roll) > self.thresholdAngle || abs(pitch) > self.thresholdAngle {
                self.isPostureCorrect = false
                self.postureMessage = NSLocalizedString("Bad Posture!", comment: "")
                
                if !wasPostureCorrect {
                    if let lastTime = self.lastNotificationTime, now.timeIntervalSince(lastTime) < self.timer {
                        return
                    }
                    self.sendNotification(title: "PoseGuard", message: "Bad Posture!")
                    self.lastNotificationTime = now
                }
            } else {
                self.isPostureCorrect = true
                self.postureMessage = NSLocalizedString("Correct Posture!", comment: "")
                
                /*if wasPostureCorrect {
                    if let lastTime = self.lastNotificationTime, now.timeIntervalSince(lastTime) < self.timer {
                        return
                    }
                    self.sendNotification(title: "PoseGuard", message: "Correct Posture!")
                    self.lastNotificationTime = now
                }*/
            }
        }
    }
    
    private func sendNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7.0, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        stopMonitoring()
    }
}

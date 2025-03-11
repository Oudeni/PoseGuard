//
//  TimeCounterViewModel.swift
//  PoseGuard (3.0)
//
//  Created by Matteo Cotena on 11/03/25.
//

import Foundation

class TimeCounterViewModel: ObservableObject {
    @Published var seconds = 0
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.seconds += 1
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    deinit {
        stopTimer()
    }
}

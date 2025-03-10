//
//  PostureViewModel.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
import Charts
import UIKit

// MARK: - ViewModel
class PostureViewModel: ObservableObject {
    @Published var sessionData: [DayData] = []
    @Published var selectedDay: DayData?
    @Published var showingDetailsModal = false
    
    var totalSessions: Int {
        sessionData.flatMap { $0.sessions }.count
    }
    
    var totalHours: Double {
        sessionData.flatMap { $0.sessions }.reduce(0) { $0 + $1.duration }
    }
    
    var averageQuality: Double {
        let sessions = sessionData.flatMap { $0.sessions }
        let weightedSum = sessions.reduce(0) { $0 + (Double($1.avgQuality) * $1.duration) }
        return sessions.isEmpty ? 0 : weightedSum / totalHours
    }
    
    var categoryCounts: [PostureCategory: Int] {
        let sessions = sessionData.flatMap { $0.sessions }
        var counts: [PostureCategory: Int] = [:]
        
        for category in PostureCategory.allCases {
            counts[category] = sessions.filter { $0.category == category }.count
        }
        
        return counts
    }
    
    var bestDay: DayData? {
        sessionData.max(by: { $0.averageQuality < $1.averageQuality })
    }
    
    var worstDay: DayData? {
        sessionData.min(by: { $0.averageQuality < $1.averageQuality })
    }
    
    init() {
        loadDemoData()
    }
    
    func loadDemoData() {
        // Array di giorni della settimana (solo lunedì-venerdì)
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        
        // Creiamo dati casuali per ogni giorno
        var randomData: [DayData] = []
        
        for day in weekdays {
            // Numero casuale di sessioni (2-4)
            let numSessions = Int.random(in: 2...4)
            var sessions: [PostureSession] = []
            
            // Orari di partenza (in ore, dalle 8 alle 17)
            var startHours = Array(8...17)
            startHours.shuffle() // Mescoliamo per avere orari casuali
            
            for i in 0..<numSessions {
                let startHour = startHours[i]
                
                // Determiniamo l'ora di inizio e fine
                let startTime = String(format: "%02d:00", startHour)
                
                // Durata casuale tra 1 e 3 ore
                let duration = Double.random(in: 1...3)
                
                // Calcoliamo l'ora di fine basata sulla durata
                let endHour = startHour + Int(duration)
                let endMinutes = (duration.truncatingRemainder(dividingBy: 1) * 60).rounded()
                let endTime = String(format: "%02d:%02d", endHour, Int(endMinutes))
                
                // Generiamo qualità casuale
                let quality = Int.random(in: 40...95)
                
                // Determiniamo la categoria basata sulla qualità
                let category: PostureCategory
                if quality >= 80 {
                    category = .buona
                } else if quality >= 60 {
                    category = .media
                } else {
                    category = .cattiva
                }
                
                // Creiamo la sessione e la aggiungiamo
                let session = PostureSession(
                    startTime: startTime,
                    endTime: endTime,
                    duration: duration,
                    avgQuality: quality,
                    category: category
                )
                
                sessions.append(session)
            }
            
            // Ordiniamo le sessioni per orario di inizio
            sessions.sort { $0.startTime < $1.startTime }
            
            // Creiamo il DayData e lo aggiungiamo
            let dayData = DayData(day: day, sessions: sessions)
            randomData.append(dayData)
        }
        
        sessionData = randomData
    }
    
    func selectDay(at point: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = point.x - geometry.frame(in: .local).origin.x
        
        // Calculate the chart area width
        let chartWidth = geometry.frame(in: .local).width
        
        // Get the total number of days displayed
        let totalDays = sessionData.count
        
        // Calculate approximate day index based on tap position
        let approximateIndex = Int((xPosition / chartWidth) * CGFloat(totalDays))
        
        // Ensure the index is within bounds
        let safeIndex = min(max(0, approximateIndex), totalDays - 1)
        
        // Select the day at that index
        self.selectedDay = sessionData[safeIndex]
        self.showingDetailsModal = true
    }
}

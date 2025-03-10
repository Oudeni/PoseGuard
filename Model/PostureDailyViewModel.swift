//
//  PostureDailyViewModel.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI

// MARK: - PostureDailyViewModel
class PostureDailyViewModel: ObservableObject {
    @Published var todayData: DayData?
    
    init() {
        loadTodayData()
    }
    
    func loadTodayData() {
        // In una situazione reale, qui caricheresti i dati del giorno corrente
        // Per scopi di demo, creiamo un esempio di dati per oggi
        
        // Esempio attivo (con dati): rimuovi il commento per vedere i dati
        createDemoData()
        
        // Esempio vuoto (senza dati): rimuovi il commento per vedere lo stato vuoto
        // todayData = nil
    }
    
    private func createDemoData() {
        // Creiamo 3 sessioni per oggi
        var sessions: [PostureSession] = []
        
        // Sessione 1 - mattina (buona)
        sessions.append(PostureSession(
            startTime: "09:00",
            endTime: "10:30",
            duration: 1.5,
            avgQuality: 85,
            category: .buona
        ))
        
        // Sessione 2 - pomeriggio (media)
        sessions.append(PostureSession(
            startTime: "13:30",
            endTime: "15:00",
            duration: 1.5,
            avgQuality: 70,
            category: .media
        ))
        
        // Sessione 3 - sera (cattiva)
        sessions.append(PostureSession(
            startTime: "16:00",
            endTime: "17:30",
            duration: 1.5,
            avgQuality: 45,
            category: .cattiva
        ))
        
        // Creiamo il DayData per oggi
        todayData = DayData(day: "Today", sessions: sessions)
    }
}

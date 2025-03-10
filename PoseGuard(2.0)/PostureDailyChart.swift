//
//  PostureDailyChart.swift
//  PoseGuard(2.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - PostureDailyChart Component
struct PostureDailyChart: View {
    @StateObject private var viewModel = PostureDailyViewModel()
    
    // Colori principali (uguali a quelli esistenti)
    private let bgColor = Color.black
    private let accentColor = Color(hex: "4CEF7E") // Verde brillante
    private let textColor = Color.white
    private let secondaryTextColor = Color.gray
    private let cardBgColor = Color(hex: "121212") // Grigio molto scuro
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            
            if viewModel.todayData != nil {
                dayDetailView
            } else {
                emptyStateView
            }
            
            Divider()
                .background(accentColor.opacity(0.3))
            
            statsView
        }
        .padding()
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: accentColor.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today's Posture")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textColor)
            
            Text("Daily statistics")
                .font(.subheadline)
                .foregroundColor(secondaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dayDetailView: some View {
        VStack(spacing: 16) {
            if let today = viewModel.todayData {
                // Indicatore di qualità
                ZStack {
                    Circle()
                        .stroke(
                            accentColor.opacity(0.2),
                            lineWidth: 15
                        )
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: today.averageQuality / 100)
                        .stroke(
                            qualityGradient,
                            style: StrokeStyle(
                                lineWidth: 15,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 150, height: 150)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(today.averageQuality))%")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(textColor)
                        
                        Text("Quality")
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor)
                    }
                }
                .padding(.vertical, 20)
                
                // Breakdown per categoria
                HStack(spacing: 20) {
                    ForEach(PostureCategory.allCases) { category in
                        let hours: Double = {
                            switch category {
                            case .buona: return today.buonaHours
                            case .media: return today.mediaHours
                            case .cattiva: return today.cattiveHours
                            }
                        }()
                        
                        if hours > 0 {
                            VStack {
                                Text(category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(textColor)
                                
                                Text("\(String(format: "%.1f", hours))h")
                                    .font(.headline)
                                    .foregroundColor(category.color)
                                
                                Text("\(Int(hours / today.totalHours * 100))%")
                                    .font(.caption)
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(category.color.opacity(0.15))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(accentColor.opacity(0.7))
                .padding(.vertical, 20)
            
            Text("No data for today")
                .font(.headline)
                .foregroundColor(textColor)
            
            Text("Wear your AirPods to start tracking your posture")
                .font(.subheadline)
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    private var statsView: some View {
        HStack {
            if let today = viewModel.todayData {
                StatView(title: "Hours", value: String(format: "%.1f", today.totalHours), icon: "clock.fill", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
                Spacer()
                StatView(title: "Quality", value: String(format: "%.1f%%", today.averageQuality), icon: "chart.bar.fill", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
                Spacer()
                StatView(title: "Sessions", value: "\(today.sessions.count)", icon: "list.bullet", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
            } else {
                StatView(title: "Hours", value: "0", icon: "clock.fill", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
                Spacer()
                StatView(title: "Quality", value: "0%", icon: "chart.bar.fill", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
                Spacer()
                StatView(title: "Sessions", value: "0", icon: "list.bullet", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
            }
        }
        .padding(.top, 4)
    }
    
    private var qualityGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                PostureCategory.cattiva.color,
                PostureCategory.media.color,
                PostureCategory.buona.color
            ]),
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(270)
        )
    }
    
    private func qualityColor(_ value: Double) -> Color {
        if value >= 80 {
            return PostureCategory.buona.color
        } else if value >= 60 {
            return PostureCategory.media.color
        } else {
            return PostureCategory.cattiva.color
        }
    }
}

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

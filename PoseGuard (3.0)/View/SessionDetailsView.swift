//
//  SessionDetailsView.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
import UIKit

struct SessionDetailsView: View {
    let day: DayData
    let accentColor: Color
    let bgColor: Color
    let textColor: Color
    
    @Environment(\.dismiss) private var dismiss
    
    private let cardBgColor = Color(hex: "121212") // Grigio molto scuro
    private let secondaryTextColor = Color.gray
    
    var body: some View {
        NavigationView {
            sessionListContent
                .scrollContentBackground(.hidden)
                .background(bgColor)
                .navigationTitle("Session Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(accentColor)
                        }
                    }
                }
        }
        .accentColor(accentColor)
    }
    
    // Suddividiamo il contenuto in sottoviste
    private var sessionListContent: some View {
        List {
            Section {
                headerSection
            }
            
            // Lista delle sessioni raggruppate per categoria
            categorySessionsSection
            
            summarySection
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(day.day)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                    
                    Text("Medium Quality: \(Int(day.averageQuality))%")
                        .font(.subheadline)
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
                
                qualityIndicator(value: day.averageQuality)
                    .scaleEffect(1.2)
            }
            
            // Grafico a torta per le percentuali di tempo nelle varie categorie
            dayBreakdownChart
                .frame(height: 80)
                .padding(.vertical, 8)
        }
        .padding(.vertical, 8)
        .listRowBackground(cardBgColor)
    }
    
    private var categorySessionsSection: some View {
        ForEach(PostureCategory.allCases) { category in
            let filteredSessions = day.sessions.filter { $0.category == category }
            if !filteredSessions.isEmpty {
                Section {
                    ForEach(filteredSessions) { session in
                        sessionRow(for: session)
                    }
                } header: {
                    categoryHeader(for: category)
                }
            }
        }
    }
    
    private func sessionRow(for session: PostureSession) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(session.startTime) - \(session.endTime)")
                    .font(.headline)
                    .foregroundColor(textColor)
                
                Text("Duration: \(String(format: "%.1f", session.duration)) hours")
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
            }
            
            Spacer()
            
            qualityIndicator(value: Double(session.avgQuality))
        }
        .padding(.vertical, 8)
        .listRowBackground(cardBgColor)
    }
    
    private func categoryHeader(for category: PostureCategory) -> some View {
        // Calcola la percentuale fuori dall'HStack
        let percentage: Double
        switch category {
        case .buona:
            percentage = day.buonaHours / day.totalHours * 100
        case .media:
            percentage = day.mediaHours / day.totalHours * 100
        case .cattiva:
            percentage = day.cattiveHours / day.totalHours * 100
        }
        
        // Ora usa il valore calcolato nella costruzione della vista
        return HStack {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
            Text(category.rawValue)
                .font(.headline)
                .foregroundColor(textColor)
            
            Spacer()
            
            Text(String(format: "%.1f%%", percentage))
                .font(.caption)
                .foregroundColor(category.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(category.color.opacity(0.2))
                .cornerRadius(10)
        }
        .foregroundColor(textColor)
    }
    
    private var summarySection: some View {
            Section {
                HStack {
                    Text("Total sessions")
                        .foregroundColor(textColor)
                    Spacer()
                    Text("\(day.sessions.count)")
                        .fontWeight(.bold)
                        .foregroundColor(accentColor)
                }
                .listRowBackground(cardBgColor)
                
                HStack {
                    Text("Total hours")
                        .foregroundColor(textColor)
                    Spacer()
                    Text("\(String(format: "%.1f", day.totalHours))")
                        .fontWeight(.bold)
                        .foregroundColor(accentColor)
                }
                .listRowBackground(cardBgColor)
            }
        }
        
        // Mantengo invariati i metodi esistenti
        private var dayBreakdownChart: some View {
            HStack(spacing: 20) {
                // Mini grafico a barre
                HStack(alignment: .bottom, spacing: 4) {
                    if day.buonaHours > 0 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(PostureCategory.buona.color)
                            .frame(width: 18, height: max(20, 60 * day.buonaHours / day.totalHours))
                    }
                    
                    if day.mediaHours > 0 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(PostureCategory.media.color)
                            .frame(width: 18, height: max(20, 60 * day.mediaHours / day.totalHours))
                    }
                    
                    if day.cattiveHours > 0 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(PostureCategory.cattiva.color)
                            .frame(width: 18, height: max(20, 60 * day.cattiveHours / day.totalHours))
                    }
                }
                .padding(.horizontal, 8)
                
                // Breakdown testuale
                VStack(alignment: .leading, spacing: 4) {
                    if day.buonaHours > 0 {
                        HStack {
                            Circle()
                                .fill(PostureCategory.buona.color)
                                .frame(width: 8, height: 8)
                            Text("Good: \(String(format: "%.1f", day.buonaHours)) hours")
                                .font(.caption)
                                .foregroundColor(textColor)
                        }
                    }
                    
                    if day.mediaHours > 0 {
                        HStack {
                            Circle()
                                .fill(PostureCategory.media.color)
                                .frame(width: 8, height: 8)
                            Text("Medium: \(String(format: "%.1f", day.mediaHours)) hours")
                                .font(.caption)
                                .foregroundColor(textColor)
                        }
                    }
                    
                    if day.cattiveHours > 0 {
                        HStack {
                            Circle()
                                .fill(PostureCategory.cattiva.color)
                                .frame(width: 8, height: 8)
                            Text("Bad: \(String(format: "%.1f", day.cattiveHours)) hours")
                                .font(.caption)
                                .foregroundColor(textColor)
                        }
                    }
                }
                
                Spacer()
            }
        }
    
    private func qualityIndicator(value: Double) -> some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.3),
                    lineWidth: 4
                )
                .frame(width: 40, height: 40)
            
            Circle()
                .trim(from: 0, to: value / 100)
                .stroke(
                    qualityColor(value),
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 40, height: 40)
            
            Text("\(Int(value))%")
                .font(.caption)
                .bold()
                .foregroundColor(textColor)
        }
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

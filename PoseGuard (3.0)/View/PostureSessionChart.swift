//
//  PostureSessionChart.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
import UIKit
import Charts

struct PostureSessionChart: View {
    @StateObject private var viewModel = PostureViewModel()
    
    // Colori principali
    private let bgColor = Color.black
    private let accentColor = Color(hex: "4CEF7E") // Verde brillante
    private let textColor = Color.white
    private let secondaryTextColor = Color.gray
    private let cardBgColor = Color(hex: "121212") // Grigio molto scuro
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            
            chartView
            
            categoryLegend
            
            Divider()
                .background(accentColor.opacity(0.3))
            
            statsView
        }
        .padding()
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: accentColor.opacity(0.2), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $viewModel.showingDetailsModal) {
            if let day = viewModel.selectedDay {
                SessionDetailsView(day: day, accentColor: accentColor, bgColor: bgColor, textColor: textColor)
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Posture Analysis")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textColor)
            
            Text("Weekly statistics")
                .font(.subheadline)
                .foregroundColor(secondaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var chartView: some View {
        GeometryReader { geometry in
            Chart {
                ForEach(viewModel.sessionData) { day in
                    // Postura cattiva (in basso)
                    BarMark(
                        x: .value("Giorno", day.day),
                        y: .value("Ore", day.cattiveHours)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PostureCategory.cattiva.color.opacity(0.7), PostureCategory.cattiva.color],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                    
                    // Postura media (al centro)
                    BarMark(
                        x: .value("Giorno", day.day),
                        y: .value("Ore", day.mediaHours)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PostureCategory.media.color.opacity(0.7), PostureCategory.media.color],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                    
                    // Postura buona (in cima)
                    BarMark(
                        x: .value("Giorno", day.day),
                        y: .value("Ore", day.buonaHours)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PostureCategory.buona.color.opacity(0.7), PostureCategory.buona.color],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: viewModel.sessionData.map { $0.day }) { day in
                    AxisValueLabel(centered: true) {
                        Text(day.as(String.self) ?? "")
                            .foregroundColor(textColor)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.top, 4)
                    }
                    
                    // Aggiungiamo un segno per ogni valore sull'asse X
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        .foregroundStyle(accentColor.opacity(0.2))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(Int(doubleValue))h")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(textColor.opacity(0.8))
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        .foregroundStyle(accentColor.opacity(0.2))
                }
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: 10)
            .chartForegroundStyleScale([
                "Good": PostureCategory.buona.color,
                "Medium": PostureCategory.media.color,
                "Bad": PostureCategory.cattiva.color
            ])
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { point in
                            // Aggiunto feedback aptico
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            
                            // Aggiungi un'animazione per evidenziare la selezione
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectDay(at: point, proxy: proxy, geometry: geometry)
                            }
                        }
                }
            }
            // Aggiungiamo un'animazione al caricamento
            .animation(.easeInOut(duration: 0.7), value: viewModel.sessionData)
        }
        .frame(height: 250)
        .padding(.top, 10)
    }
    
    private var categoryLegend: some View {
        HStack(spacing: 12) {
            ForEach(PostureCategory.allCases) { category in
                VStack {
                    Image(systemName: category.icon)
                        .foregroundColor(category.color)
                        .font(.system(size: 18))
                    
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor)
                    
                    Text("\(viewModel.categoryCounts[category] ?? 0) sess.")
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
    
    private var statsView: some View {
        HStack {
            StatView(title: "Hours", value: String(format: "%.1f", viewModel.totalHours), icon: "clock.fill", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
            Spacer()
            StatView(title: "Quality", value: String(format: "%.1f%%", viewModel.averageQuality), icon: "chart.bar.fill", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
            Spacer()
            StatView(title: "Sessions", value: "\(viewModel.totalSessions)", icon: "list.bullet", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
        }
        .padding(.top, 4)
    }
}



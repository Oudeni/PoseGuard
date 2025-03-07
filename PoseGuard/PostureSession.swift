//
//  PostureSession.swift
//  PoseGuard
//
//  Created by Acri Stefano on 06/03/25.
//

import SwiftUI
import Charts

// MARK: - Modelli di dati
struct PostureSession: Identifiable {
    let id = UUID()
    let startTime: String
    let endTime: String
    let duration: Double
    let avgQuality: Int
    let category: PostureCategory
}

enum PostureCategory: String, CaseIterable, Identifiable {
    case buona = "Buona"
    case media = "Media"
    case cattiva = "Cattiva"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .buona: return Color(hex: "4CEF7E") // Verde brillante
        case .media: return Color(hex: "FFD700") // Giallo oro
        case .cattiva: return Color(hex: "FF5252") // Rosso
        }
    }
    
    var icon: String {
        switch self {
        case .buona: return "checkmark.circle.fill"
        case .media: return "exclamationmark.circle.fill"
        case .cattiva: return "xmark.circle.fill"
        }
    }
}

struct DayData: Identifiable {
    let id = UUID()
    let day: String
    let sessions: [PostureSession]
    
    // Ore raggruppate per categoria
    var buonaHours: Double {
        sessions.filter { $0.category == .buona }.reduce(0) { $0 + $1.duration }
    }
    
    var mediaHours: Double {
        sessions.filter { $0.category == .media }.reduce(0) { $0 + $1.duration }
    }
    
    var cattiveHours: Double {
        sessions.filter { $0.category == .cattiva }.reduce(0) { $0 + $1.duration }
    }
    
    // Statistiche giornaliere
    var totalHours: Double {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var averageQuality: Double {
        let weightedSum = sessions.reduce(0) { $0 + (Double($1.avgQuality) * $1.duration) }
        return sessions.isEmpty ? 0 : weightedSum / totalHours
    }
}

// Estensione per convertire codici esadecimali in Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Classe ViewModel
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
        // Dati di esempio
        sessionData = [
            DayData(day: "Lunedì", sessions: [
                PostureSession(startTime: "09:00", endTime: "10:30", duration: 1.5, avgQuality: 88, category: .buona),
                PostureSession(startTime: "11:00", endTime: "12:30", duration: 1.5, avgQuality: 65, category: .media),
                PostureSession(startTime: "15:00", endTime: "16:30", duration: 1.5, avgQuality: 45, category: .cattiva)
            ]),
            DayData(day: "Martedì", sessions: [
                PostureSession(startTime: "08:30", endTime: "09:30", duration: 1, avgQuality: 92, category: .buona),
                PostureSession(startTime: "10:00", endTime: "12:00", duration: 2, avgQuality: 89, category: .buona),
                PostureSession(startTime: "14:00", endTime: "15:00", duration: 1, avgQuality: 75, category: .media)
            ]),
            DayData(day: "Mercoledì", sessions: [
                PostureSession(startTime: "09:30", endTime: "10:30", duration: 1, avgQuality: 52, category: .cattiva),
                PostureSession(startTime: "11:00", endTime: "13:00", duration: 2, avgQuality: 62, category: .media),
                PostureSession(startTime: "14:30", endTime: "17:30", duration: 3, avgQuality: 91, category: .buona)
            ]),
            DayData(day: "Giovedì", sessions: [
                PostureSession(startTime: "08:00", endTime: "10:00", duration: 2, avgQuality: 78, category: .media),
                PostureSession(startTime: "11:30", endTime: "13:30", duration: 2, avgQuality: 81, category: .buona),
                PostureSession(startTime: "15:00", endTime: "16:00", duration: 1, avgQuality: 55, category: .cattiva)
            ]),
            DayData(day: "Venerdì", sessions: [
                PostureSession(startTime: "09:00", endTime: "11:00", duration: 2, avgQuality: 90, category: .buona),
                PostureSession(startTime: "12:00", endTime: "13:00", duration: 1, avgQuality: 48, category: .cattiva),
                PostureSession(startTime: "15:00", endTime: "18:00", duration: 3, avgQuality: 72, category: .media)
            ])
        ]
    }
    
    func selectDay(at point: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = point.x - geometry.frame(in: .local).origin.x
        
        if let day = proxy.value(atX: xPosition) as String?,
           let selectedDay = sessionData.first(where: { $0.day == day }) {
            self.selectedDay = selectedDay
            self.showingDetailsModal = true
        }
    }
}

// MARK: - Vista principale
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
            Text("Analisi Postura")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textColor)
            
            Text("Statistiche settimanali")
                .font(.subheadline)
                .foregroundColor(secondaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var chartView: some View {
        GeometryReader { geometry in
            Chart {
                ForEach(viewModel.sessionData) { day in
                    BarMark(
                        x: .value("Giorno", day.day),
                        y: .value("Ore", day.cattiveHours)
                    )
                    .foregroundStyle(PostureCategory.cattiva.color)
                    .cornerRadius(2)
                    
                    BarMark(
                        x: .value("Giorno", day.day),
                        y: .value("Ore", day.mediaHours)
                    )
                    .foregroundStyle(PostureCategory.media.color)
                    .cornerRadius(2)
                    
                    BarMark(
                        x: .value("Giorno", day.day),
                        y: .value("Ore", day.buonaHours)
                    )
                    .foregroundStyle(PostureCategory.buona.color)
                    .cornerRadius(4)
                }
                
                if let bestDay = viewModel.bestDay {
                    RuleMark(x: .value("Miglior giorno", bestDay.day))
                        .foregroundStyle(accentColor.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(accentColor)
                                .font(.caption)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(values: viewModel.sessionData.map { $0.day }) { day in
                    AxisValueLabel(centered: true) {
                        Text(day.as(String.self) ?? "")
                            .foregroundColor(textColor)
                            .font(.caption)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(Int(doubleValue))h")
                                .font(.caption)
                                .foregroundColor(textColor)
                        }
                    }
                }
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: 10)
            .chartForegroundStyleScale([
                "Buona": PostureCategory.buona.color,
                "Media": PostureCategory.media.color,
                "Cattiva": PostureCategory.cattiva.color
            ])
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { point in
                            viewModel.selectDay(at: point, proxy: proxy, geometry: geometry)
                        }
                }
            }
        }
        .frame(height: 250)
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
            StatView(title: "Ore", value: String(format: "%.1f", viewModel.totalHours), icon: "clock.fill", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
            Spacer()
            StatView(title: "Qualità", value: String(format: "%.1f%%", viewModel.averageQuality), icon: "chart.bar.fill", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
            Spacer()
            StatView(title: "Sessioni", value: "\(viewModel.totalSessions)", icon: "list.bullet", accentColor: accentColor, textColor: textColor, secondaryTextColor: secondaryTextColor)
        }
        .padding(.top, 4)
    }
}

// MARK: - Vista dettaglio statistiche
struct StatView: View {
    let title: String
    let value: String
    let icon: String
    let accentColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 16))
            
            Text(value)
                .font(.headline)
                .foregroundColor(textColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(secondaryTextColor)
        }
    }
}

// MARK: - Vista modale per i dettagli
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
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(day.day)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(textColor)
                            
                            Text("Qualità media: \(Int(day.averageQuality))%")
                                .font(.subheadline)
                                .foregroundColor(secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        qualityIndicator(value: day.averageQuality)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(cardBgColor)
                }

                ForEach(PostureCategory.allCases) { category in
                    if !day.sessions.filter({ $0.category == category }).isEmpty {
                        Section {
                            ForEach(day.sessions.filter { $0.category == category }) { session in
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(session.startTime) - \(session.endTime)")
                                            .font(.headline)
                                            .foregroundColor(textColor)
                                        
                                        Text("Durata: \(String(format: "%.1f", session.duration)) ore")
                                            .font(.subheadline)
                                            .foregroundColor(secondaryTextColor)
                                    }
                                    
                                    Spacer()
                                    
                                    qualityIndicator(value: Double(session.avgQuality))
                                }
                                .padding(.vertical, 8)
                                .listRowBackground(cardBgColor)
                            }
                        } header: {
                            Label {
                                Text(category.rawValue).font(.headline)
                            } icon: {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                            }
                            .foregroundColor(textColor)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Totale sessioni")
                            .foregroundColor(textColor)
                        Spacer()
                        Text("\(day.sessions.count)")
                            .fontWeight(.bold)
                            .foregroundColor(accentColor)
                    }
                    .listRowBackground(cardBgColor)
                    
                    HStack {
                        Text("Ore totali")
                            .foregroundColor(textColor)
                        Spacer()
                        Text("\(String(format: "%.1f", day.totalHours))")
                            .fontWeight(.bold)
                            .foregroundColor(accentColor)
                    }
                    .listRowBackground(cardBgColor)
                }
            }
            .scrollContentBackground(.hidden)
            .background(bgColor)
            .navigationTitle("Dettaglio Sessioni")
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

// MARK: - Content View per App
struct PostureApp: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    PostureSessionChart()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("Monitoraggio Postura")
            .background(Color.black)
            .foregroundColor(Color.white)
        }
        .preferredColorScheme(.dark) // Forza la dark mode
        .accentColor(Color(hex: "4CEF7E")) // Verde brillante
    }
}

// MARK: - Preview
struct PostureSessionChart_Previews: PreviewProvider {
    static var previews: some View {
        PostureApp()
    }
}

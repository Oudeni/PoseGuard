import Foundation

import SwiftUI
import UIKit
import Charts

struct PostureSession: Identifiable, Equatable {
    let id = UUID()
    let startTime: String
    let endTime: String
    let duration: Double
    let avgQuality: Int
    let category: PostureCategory
    
    // Implementazione di Equatable
    static func == (lhs: PostureSession, rhs: PostureSession) -> Bool {
        lhs.id == rhs.id
    }
}

enum PostureCategory: String, CaseIterable, Identifiable {
    case buona = "Good"
    case media = "Medium"
    case cattiva = "Bad"
    
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CustomRoundedCornerShape(radius: radius, corners: corners))
    }
}

struct CustomRoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}



struct DayData: Identifiable, Equatable {
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
    
    // Implementazione di Equatable
    static func == (lhs: DayData, rhs: DayData) -> Bool {
        lhs.id == rhs.id && lhs.day == rhs.day
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

// MARK: - StatView and Components
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

// MARK: - PostureSessionChart Component
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

struct MyReportView: View {
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var selectedReportType: ReportType = .weekly
    
    // Colori principali
    private let bgColor = Color.black
    private let accentColor = Color(hex: "4CEF7E") // Verde brillante
    private let textColor = Color.white
    private let secondaryTextColor = Color.gray
    private let cardBgColor = Color(hex: "121212") // Grigio molto scuro
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if isShowing {
                    // Semi-transparent background overlay
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            hideView()
                        }
                }
                
                // Main report content
                VStack(spacing: 0) {
                    // Drag indicator
                    Rectangle()
                        .frame(width: 60, height: 5)
                        .cornerRadius(2.5)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 15)
                        .padding(.bottom, 10)
                    
                    // Title section
                    HStack {
                        Text("My Report")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                    
                    // Report Type Selector
                    ReportTypeSelector(
                        selectedType: $selectedReportType,
                        accentColor: accentColor,
                        textColor: textColor,
                        backgroundColor: cardBgColor
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 15)
                    
                    // Content area with selected chart
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            if selectedReportType == .weekly {
                                PostureSessionChart()
                                    .padding(.horizontal, 16)
                            } else {
                                PostureDailyChart()
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.85)
                .background(Color(UIColor.darkGray).opacity(0.99))
                .cornerRadius(25, corners: [.topLeft, .topRight])
                .offset(y: offset)
                .gesture(
                    // Gesture for dragging the panel
                    DragGesture(minimumDistance: 5, coordinateSpace: .global)
                        .onChanged { value in
                            // Only allow dragging down
                            let newOffset = value.translation.height
                            if newOffset > 0 {
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.3)) {
                                    offset = newOffset
                                }
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 50 || value.velocity.height > 100 {
                                hideView()
                            } else {
                                // Otherwise snap back
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    offset = 0
                                }
                            }
                        }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
        .opacity(isShowing ? 1 : 0)
        .onChange(of: isShowing) { newValue in
            if newValue {
                showView()
            }
        }
    }
    
    // Animation for showing the view
    private func showView() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = 0
        }
    }
    
    // Animation for hiding the view
    private func hideView() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = UIScreen.main.bounds.height
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isShowing = false
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        MyReportView(isShowing: .constant(true))
    }
}

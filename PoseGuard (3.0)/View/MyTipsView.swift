//
//  MyTipsView.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Tip Card Component
struct TipCard: View {
    let tip: PostureTip
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Tip icon
            VStack(alignment: .center) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "figure.walk")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Title and timestamp
                HStack {
                    Text(tip.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
//                    
//                    Text(tip.timeString)
//                        .font(.caption)
//                        .foregroundColor(.gray)
                }
                
                // Description
                Text(tip.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(UIColor.darkGray).opacity(0.2))
        .cornerRadius(16)
    }
}

// MARK: - Tips View
struct MyTipsView: View {
    @Binding var isShowing: Bool
    @StateObject private var viewModel = TipsViewModel()
    @State private var offset: CGFloat = -UIScreen.main.bounds.height
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if isShowing {
                    // Semi-transparent background overlay
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            hideView()
                        }
                }
                
                // Tips panel
                VStack(spacing: 0) {
                    // Spazio aggiuntivo per evitare la sovrapposizione con la barra di stato
                    Spacer()
                        .frame(height: 40)
                        
                    // Header
                    HStack {
                        Text("Tips")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    
                    // Tips list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.tips) { tip in
                                TipCard(tip: tip)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                    
                    // Home indicator - ridotta dimensione
                    Rectangle()
                        .frame(width: 80, height: 4)
                        .cornerRadius(2)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 5)
                }
                .frame(width: geometry.size.width, height: geometry.size.height - 100)
                .background(Color.black.opacity(0.99))
                .cornerRadius(25, corners: [.topLeft, .topRight])
                .offset(y: offset)
                .gesture(
                    // Gesture for dragging the panel
                    DragGesture(minimumDistance: 5, coordinateSpace: .global)
                        .onChanged { value in
                            // Only allow dragging up (negative values)
                            let newOffset = value.translation.height
                            if newOffset < 0 {
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.3)) {
                                    offset = newOffset
                                }
                            }
                        }
                        .onEnded { value in
                            if value.translation.height < -50 || value.velocity.height < -100 {
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
            .onChange(of: isShowing) { newValue in
                if newValue {
                    showView()
                }
            }
        }
        .opacity(isShowing ? 1 : 0)
    }
    
    // Animation for showing the view
    private func showView() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = 0  // Impostato a 0 per visualizzare completamente il pannello dall'alto
        }
    }
    
    // Animation for hiding the view
    private func hideView() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = -UIScreen.main.bounds.height
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isShowing = false
            }
        }
    }
}

//
//  TipsView.swift
//  PoseGuard
//
//  Created by Acri Stefano on 06/03/25.
//

import SwiftUI

struct TipsView: View {
    @Binding var isTipsVisible: Bool

    let tips = [
        "Keep your shoulders back!",
        "Engage your core!",
        "Keep your feet flat on the ground!",
        "Align your ears with your shoulders!",
        "Take breaks regularly!",
        "Adjust your screen height!"
    ]

    var body: some View {
        VStack {
            Text("Tips")
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(tips, id: \.self) { tip in
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.green)
                            VStack(alignment: .leading) {
                                Text(tip)
                                    .font(.body)
                                    .bold()
                                    .foregroundColor(.white)
                                Text("Follow this to maintain good posture.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("9:41 AM")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(UIColor.darkGray).opacity(0.8))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }

            // Small drag handle at the bottom
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray)
                .padding(10)
                .onTapGesture {
                    withAnimation {
                        isTipsVisible = false
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .background(Color.black) // Ensure the background under the modal is black
        .cornerRadius(20)
        .shadow(radius: 10)
        .edgesIgnoringSafeArea(.bottom)
    }
}

// ✅ CORRECT PREVIEW WITH A DUMMY STATE WRAPPER
struct TipsView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isTipsVisible = true  // Define state in a wrapper

        var body: some View {
            TipsView(isTipsVisible: $isTipsVisible)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}

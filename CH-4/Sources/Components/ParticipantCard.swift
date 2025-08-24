//
//  ParticipantCard.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI

struct ParticipantCard: View {
    var image: Image
    var name: String
    var title: String
    var onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Card background with neon border
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 6
                        )
                        .blur(radius: 0.5)
                        .opacity(0.9)
                )
                .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)

            // Photo
            image
                .resizable()
                .scaledToFill()
                .frame(height: 380)
                .clipped()
                .cornerRadius(18)
                .padding(10)

            // Bottom gradient + texts
            VStack(spacing: 8) {
                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 140)
                .mask(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .padding(10)
                )
                .overlay(
                    VStack(spacing: 6) {
                        Text(name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)

                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))

                        Text("Tap to see detail")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.top, 6)
                    }
                    .padding(.bottom, 24)
                )
            }
        }
        .frame(height: 440)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ParticipantCard(
            image: Image("leonie"),
            name: "Leonie Marie Gogh",
            title: "Technopreneur",
            onTap: { print("Show participant details") }
        )
        .padding(.horizontal, 20)
    }
}

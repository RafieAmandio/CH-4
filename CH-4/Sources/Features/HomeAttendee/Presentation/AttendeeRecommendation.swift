//
//  AttendeeRecommendation.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI

struct AttendeeRecommendationView: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.black, Color(red: 0.10, green: 0.12, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                HeaderView()

                Text("We’ve found participants who could\nbe valuable connections for you.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                ParticipantCard(
                    image: Image("leonie"),            // Add asset named "leonie"
                    name: "Leonie Marie Gogh",
                    title: "Technopreneur",
                    onTap: { print("Show participant details") }
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 12)

                RefreshButton(action: { print("Refresh tapped") })
                    .padding(.bottom, 24)
            }
            .padding(.top, 20)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Header

private struct HeaderView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Current Event")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)

                Text("TechnoFest 2025")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            // Profile bubble
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
    }
}



// MARK: - Preview

#Preview {
    AttendeeRecommendationView()
}

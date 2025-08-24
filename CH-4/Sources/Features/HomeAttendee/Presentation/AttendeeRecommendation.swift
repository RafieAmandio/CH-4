//
//  AttendeeRecommendation.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI

struct AttendeeRecommendationView: View {
    let sampleCards = [
        ParticipantCardData(
            image: Image("abg"),
            name: "John Doe",
            title: "iOS Developer",
            detailContent: AnyView(
                VStack {
                    Text("Detailed Information")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("More details about the person...")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            ),
            onTap: { print("Card tapped") }
        ),

        ParticipantCardData(
            image: Image("abg"),
            name: "Jane Smith",
            title: "UI/UX Designer",
            detailContent: AnyView(
                VStack {
                    Text("Detailed Information")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("More details about the person...")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            ),
            onTap: { print("Card tapped") }
        ),

        ParticipantCardData(
            image: Image("abg"),
            name: "Mike Johnson",
            title: "Product Manager",
            detailContent: AnyView(
                VStack {
                    Text("Detailed Information")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("More details about the person...")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            ),
            onTap: { print("Card tapped") }
        ),

        ParticipantCardData(
            image: Image("abg"),
            name: "Sarah Wilson",
            title: "Data Scientist",
            detailContent: AnyView(
                VStack {
                    Text("Detailed Information")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("More details about the person...")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            ),
            onTap: { print("Card tapped") }
        ),

        ParticipantCardData(
            image: Image("abg"),
            name: "David Brown",
            title: "DevOps Engineer",
            detailContent: AnyView(
                VStack {
                    Text("Detailed Information")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("More details about the person...")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            ),
            onTap: { print("Card tapped") }
        ),
    ]
    var body: some View {
        VStack(spacing: 24) {
            Text(
                "We’ve found participants who could\nbe valuable connections for you."
            )
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.white.opacity(0.9))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            ParticipantCardStack(cards: sampleCards)
                .frame(height: 500)
                .padding(.horizontal, 40)

            //            FlexibleParticipantCard(
            //                image: Image("abg"),
            //                name: "John Doe",
            //                title: "iOS Developer",
            //                detailContent: AnyView(
            //                    VStack {
            //                        Text("Detailed Information")
            //                            .font(.title2)
            //                            .foregroundColor(.white)
            //                        Text("More details about the person...")
            //                            .foregroundColor(.white.opacity(0.8))
            //                    }
            //                    .padding()
            //                ),
            //                onTap: { print("Card tapped") }
            //            )

            CustomButton(title: "Refresh", style: .primary, width: 116) {

            }

        }
    }
}

// MARK: - Preview

#Preview {
    AttendeeRecommendationView()
}

struct ExtractedView: View {
    var body: some View {
        CustomButton(title: "Refresh", style: .primary, width: 116) {

        }
    }
}

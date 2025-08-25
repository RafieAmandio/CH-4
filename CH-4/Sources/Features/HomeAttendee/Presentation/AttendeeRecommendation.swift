//
//  AttendeeRecommendation.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI
import UIComponentsKit

struct AttendeeRecommendationView: View {
    @EnvironmentObject var viewModel: HomeAttendeeViewModel

    var body: some View {
        ZStack {
            contentView
            //            if viewModel.isLoadingRecommendations {
            //                // Loading state
            //                loadingView
            //            } else if let error = viewModel.recommendationError {
            //                // Error state
            //                errorView(error: error)
            //            } else if viewModel.recommendations.isEmpty {
            //                // Empty state
            //                emptyStateView
            //            } else {
            //                // Content with recommendations
            //                contentView
            //            }
        }
        .onAppear {
            viewModel.onViewAppear()
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)

            Text("Finding your connections...")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    // MARK: - Error View
    private func errorView(error: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)

                Text("Failed to load recommendations")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)

                Text(error)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            CustomButton(title: "Retry", style: .primary, width: 116) {
                Task {
                    await viewModel.fetchRecommendations()
                }
            }
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "person.2.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)

                Text("No recommendations yet")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)

                Text("Join an event to find potential connections")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            CustomButton(title: "Refresh", style: .primary, width: 116) {
                Task {
                    await viewModel.fetchRecommendations()
                }
            }
        }
    }

    // MARK: - Content View (FIXED)
    private var contentView: some View {
        VStack(spacing: 20) {
            // Header text section with proper constraints
            VStack(spacing: 8) {
                Text(
                    "We've found participants who could be valuable connections for you."
                )
                .font(AppFont.bodySmallMedium)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(nil)  // Allow multiple lines
                .fixedSize(horizontal: false, vertical: true)  // Allow vertical expansion
                .padding(.horizontal, 20)  // Add side padding to prevent edge cutoff

            }
            .frame(maxWidth: .infinity)  // Take full width

            // Card stack with flexible height
            ParticipantCardStack(
                cards: viewModel.recommendations.map {
                    $0.toParticipantCardData()
                }
            )
            .frame(minHeight: 400, maxHeight: 450)  // Use min/max instead of fixed height
            .layoutPriority(1)  // Give priority to card stack for space

            // Spacer to push button to bottom
            Spacer(minLength: 10)

            // Refresh button
            CustomButton(title: "Refresh", style: .primary, width: 116) {
                Task {
                    await viewModel.fetchRecommendations(forceRefresh: true)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Take all available space

    }
}

// MARK: - Alternative Content View (If above doesn't work)
extension AttendeeRecommendationView {
    private var alternativeContentView: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Header section - fixed height
                VStack(spacing: 8) {
                    Text(
                        "We've found participants who could be valuable connections for you."
                    )
                    .font(AppFont.bodySmallMedium)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)  // Allow up to 3 lines
                    .minimumScaleFactor(0.8)  // Scale down if needed
                    .padding(.horizontal, 24)

                    Text("\(viewModel.recommendations.count) potential matches")
                        .font(AppFont.bodySmallMedium)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(height: 80)  // Fixed height for header

                // Card stack - flexible height based on remaining space
                ParticipantCardStack(
                    cards: viewModel.recommendations.map {
                        $0.toParticipantCardData()
                    }
                )
                .frame(height: geometry.size.height - 160)  // Leave space for header and button

                // Button section - fixed height
                CustomButton(title: "Refresh", style: .primary, width: 116) {
                    Task {
                        await viewModel.fetchRecommendations(forceRefresh: true)
                    }
                }
                .frame(height: 50)  // Fixed button height
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    AttendeeRecommendationView()
}

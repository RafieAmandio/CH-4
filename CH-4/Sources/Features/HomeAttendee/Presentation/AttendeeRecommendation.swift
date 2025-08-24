//
//  AttendeeRecommendation.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI

struct AttendeeRecommendationView: View {
    @EnvironmentObject var viewModel: HomeAttendeeViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isLoadingRecommendations {
                // Loading state
                loadingView
            } else if let error = viewModel.recommendationError {
                // Error state
                errorView(error: error)
            } else if viewModel.recommendations.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Content with recommendations
                contentView
            }
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
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("We've found participants who could\nbe valuable connections for you.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Text("\(viewModel.recommendations.count) potential matches")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
            }

            ParticipantCardStack(
                cards: viewModel.recommendations.map { $0.toParticipantCardData() }
            )
            .frame(height: 500)
                
            Spacer()

            CustomButton(title: "Refresh", style: .primary, width: 116) {
                Task {
                    await viewModel.fetchRecommendations()
                }
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

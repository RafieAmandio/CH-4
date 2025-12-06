//
//  GoalSelectionView.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import SwiftUI
import UIComponentsKit

struct GoalSelectionView: View {
    @State private var selectedGoal: GoalsCategory?  // Single selection
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            HeaderView

            // Options List
            VStack(spacing: 16) {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.goals, id: \.id) { goal in
                            let isSelected = selectedGoal?.id == goal.id

                            GoalSelectionButton(
                                title: goal.name,
                                isSelected: isSelected
                            ) {
                                handleGoalSelection(goal: goal)
                            }
                        }
                    }
                }
            }

            Spacer()

            // Continue Button
            VStack(spacing: 16) {
                CustomButton(title: "Continue", style: .newPrimary) {
                    handleContinueAction()
                }
                .disabled(selectedGoal == nil)
                .opacity(selectedGoal == nil ? 0.6 : 1.0)
            }
        }
        .padding(20)
        .onAppear {
            Task {
                await viewModel.fetchGoals()
            }
        }
    }

    // MARK: - Header
    private var HeaderView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Why did you join this event?")
                .font(AppFont.interLargeSemiBold)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text("Pick a goal — Your answer helps us match you with the best connections.")
                .font(AppFont.interMidRegular)
                .multilineTextAlignment(.leading)
        }
    }

    // MARK: - Helpers
    private func handleGoalSelection(goal: GoalsCategory) {
        if selectedGoal?.id == goal.id {
            selectedGoal = nil
        } else {
            selectedGoal = goal
        }
    }

    private func handleContinueAction() {
        guard let selectedGoal = selectedGoal else {
            print("No goal selected")
            return
        }
        Task {
            try await viewModel.submitGoal(
                payload: SubmitGoalPayload(goalsCategoryId: selectedGoal.id)
            )
        }
    }
}

struct GoalSelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Radio button indicator (same as SingleSelectOptionButton)
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? AppColors.primary : Color.gray.opacity(0.4),
                            lineWidth: isSelected ? 2 : 1
                        )
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(title)
                    .font(AppFont.interMidMedium)
                    .foregroundColor(isSelected ? AppColors.primary : .primary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Background fill
                    RoundedRectangle(cornerRadius: 11)
                        .fill(AppColors.TextFieldBackground)

                    // Border INSIDE the shape (no clipping)
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(
                            isSelected ? AppColors.primary : Color.gray.opacity(0.4),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    let vm = OnBoardingDIContainer.shared.makeOnBoardingViewModel()
    vm.goals = [
        GoalsCategory(id: "1", name: "Networking"),
        GoalsCategory(id: "2", name: "Learning"),
        GoalsCategory(id: "3", name: "Career Growth")
    ]
    return GoalSelectionView()
        .environmentObject(vm)
}

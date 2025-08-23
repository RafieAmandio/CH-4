//
//  GoalSelectionView.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import SwiftUI
import UIComponentsKit

struct GoalSelectionView: View {
    @State private var selectedGoal: GoalsCategory? // Single selection

    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        ApplyBackground {
            VStack {
                VStack(spacing: 45) {
                    HeaderView
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.goals, id: \.id) { goal in
                                let isSelected = selectedGoal?.id == goal.id

                                SelectableRectangleView(
                                    title: goal.name,
                                    isSelected: isSelected,
                                    selectionMode: .single
                                ) {
                                    handleGoalSelection(goal: goal)
                                }
                            }
                        }
                    }
                    
                    selectedGoalView
                }
                Spacer()
                
                CustomButton(title: "Continue", style: .primary) {
                    handleContinueAction()
                }
            }
            .padding(20)
        }
        .onAppear{
            Task {
                 await viewModel.fetchGoals()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    @ViewBuilder
    private var selectedGoalView: some View {
        if let selectedGoal = selectedGoal {
            VStack {
                Text("Selected:")
                    .font(AppFont.bodySmallMedium)
                    .fontWeight(.semibold)

                Text(selectedGoal.name)
                    .font(AppFont.bodySmallMedium)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 20)
        }
    }
    
    private var HeaderView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Why did you join this event?")
                .font(AppFont.headingLargeBold)
            Text("Pick a goal — Your answer helps us match you with the best connections.")
                .font(AppFont.bodySmallMedium)
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleGoalSelection(goal: GoalsCategory) {
        if selectedGoal?.id == goal.id {
            // Deselect if already selected
            selectedGoal = nil
        } else {
            // Select the new goal
            selectedGoal = goal
        }
        
    }
    
    private func handleContinueAction() {
        guard let selectedGoal = selectedGoal else {
            print("No goal selected")
            return
        }
        Task {
            try await viewModel.submitGoal(payload: SubmitGoalPayload(goalsCategoryId: selectedGoal.id))

        }
    }
}

#Preview {
    GoalSelectionView()
}

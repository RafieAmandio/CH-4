//
//  GoalSelectionView.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import SwiftUI
import UIComponentsKit

struct GoalSelectionView: View {
    @State private var selectedGoals: [GoalsCategory] = []
    @State private var goals: [GoalsCategory] = GoalsCategory.mockData

    var body: some View {
        ApplyBackground {
            VStack {
                VStack(spacing: 45) {
                    HeaderView
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(goals, id: \.id) { goal in
                                let isSelected = selectedGoals.contains {
                                    $0.id == goal.id
                                }
                                let canSelect =
                                    selectedGoals.count < 3 || isSelected

                                SelectableRectangleView(
                                    title: goal.name,
                                    isSelected: isSelected,
                                    selectionMode: .multiple
                                ) {
                                    if let index = selectedGoals.firstIndex(
                                        where: { $0.id == goal.id })
                                    {
                                        selectedGoals.remove(at: index)
                                    } else if canSelect {
                                        selectedGoals.append(goal)
                                    }
                                    print(
                                        "Selected goal IDs: \(selectedGoals.map(\.id))"
                                    )
                                }
                                .opacity(canSelect ? 1.0 : 0.6)
                                .disabled(!canSelect)
                            }
                        }
                    }
                    if !selectedGoals.isEmpty {
                        VStack {
                            Text("Selected (\(selectedGoals.count)/3):")
                                .font(AppFont.bodySmallMedium)
                                .fontWeight(.semibold)

                            Text(
                                selectedGoals.map(\.name).joined(
                                    separator: ", ")
                            )
                            .font(AppFont.bodySmallMedium)
                            .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    }
                }
                Spacer()
                CustomButton(title: "Continue", style: .primary) {
                }
            }
            .padding(20)
        }
    }
}

private var HeaderView: some View {
    VStack(alignment: .leading, spacing: 10) {
        Text("Why did you join this event?")
            .font(AppFont.headingLargeBold)
        Text(
            "Pick a goal — Your answer helps us match you with the best connections."
        )
        .font(AppFont.bodySmallMedium)
    }

}
#Preview {
    GoalSelectionView()
}

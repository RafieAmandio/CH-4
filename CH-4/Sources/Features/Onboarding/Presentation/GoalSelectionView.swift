//
//  GoalSelectionView.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import SwiftUI
import UIComponentsKit

struct GoalSelectionView: View {
    @State private var selectedGoal: String? = nil

    private let goals = [
        "Job Seeking & Career Growth",
        "Investment",
        "Networking & Relationship Building",
        "Investor",
        "Learning & Skill Development",
        "Business Development",
    ]

    var body: some View {
        ApplyBackground {
            VStack {
                VStack(spacing: 45) {
                    HeaderView
                    LazyVStack(spacing: 15) {
                        ForEach(goals, id: \.self) { goal in
                            SelectableRectangleView(
                                title: goal,
                                isSelected: selectedGoal == goal,
                                selectionMode:.multiple
                            ) {
                                selectedGoal = goal
                            }
                        }
                    }
                }
                Spacer()
                CustomButton(title: "Continue", style: .primary) {
                }
            }
            .padding(.horizontal, 20)
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

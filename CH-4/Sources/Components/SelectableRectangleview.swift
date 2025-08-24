import SwiftUI
import UIComponentsKit

struct SelectableRectangleView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let selectionMode: SelectionMode

    // Customizable properties
    var cornerRadius: CGFloat = 20
    var height: CGFloat = 56
    var unselectedColor: Color = AppColors.TextFieldBackground
    var selectedBorderColor: Color = AppColors.selectedBorder
    var unselectedBorderColor: Color = .clear
    var borderWidth: CGFloat = 2
    var textColor: Color = .primary
    var selectedTextColor: Color = .white

    enum SelectionMode {
        case single
        case multiple
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppFont.bodySmallMedium)
                    .foregroundColor(isSelected ? selectedTextColor : textColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if selectionMode == .multiple {
                    Image(
                        systemName: isSelected
                            ? "checkmark.circle.fill" : "circle"
                    )
                    .foregroundColor(
                        isSelected ? selectedTextColor : textColor.opacity(0.6)
                    )
                    .font(.title3)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(unselectedColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                isSelected
                                    ? selectedBorderColor
                                    : unselectedBorderColor,
                                lineWidth: borderWidth
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Convenience Initializers
extension SelectableRectangleView {
    
    /// Single selection mode (default)
    init(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
        self.selectionMode = .single
    }
    
    /// Multiple selection mode
    init(
        title: String,
        isSelected: Bool,
        selectionMode: SelectionMode,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
        self.selectionMode = selectionMode
    }
}


// Multiple selection example
struct MultipleGoalSelectionView: View {
    @State private var selectedGoals: [GoalsCategory] = []
    @State private var goals: [GoalsCategory] = []
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(goals, id: \.id) { goal in
                SelectableRectangleView(
                    title: goal.name,
                    isSelected: selectedGoals.contains { $0.id == goal.id },
                    selectionMode: .multiple
                ) {
                    if let index = selectedGoals.firstIndex(where: { $0.id == goal.id }) {
                        selectedGoals.remove(at: index)
                    } else {
                        selectedGoals.append(goal)
                    }
                }
            }
        }
    }
}

// Using Set for better performance with many items
struct SetBasedGoalSelectionView: View {
    @State private var selectedGoalIDs: Set<String> = []
    @State private var goals: [GoalsCategory] = []
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(goals, id: \.id) { goal in
                SelectableRectangleView(
                    title: goal.name,
                    isSelected: selectedGoalIDs.contains(goal.id),
                    selectionMode: .multiple
                ) {
                    if selectedGoalIDs.contains(goal.id) {
                        selectedGoalIDs.remove(goal.id)
                    } else {
                        selectedGoalIDs.insert(goal.id)
                    }
                }
            }
        }
    }
}

// With OnboardingViewModel integra

extension GoalsCategory {
    static let mockData: [GoalsCategory] = [
        GoalsCategory(id: "goal-001", name: "Job Seeking & Career Growth"),
        GoalsCategory(id: "goal-002", name: "Investment"),
        GoalsCategory(id: "goal-003", name: "Networking & Relationship Building"),
        GoalsCategory(id: "goal-004", name: "Investor"),
        GoalsCategory(id: "goal-005", name: "Learning & Skill Development"),
        GoalsCategory(id: "goal-006", name: "Business Development"),
        GoalsCategory(id: "goal-007", name: "Startup Funding"),
        GoalsCategory(id: "goal-008", name: "Mentorship"),
    ]
}

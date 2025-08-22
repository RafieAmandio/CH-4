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

// MARK: - Selection Helper Views
struct SingleSelectionList<T: Hashable>: View {
    let items: [T]
    let selectedItem: T?
    let onSelection: (T) -> Void
    let itemTitle: (T) -> String
    let spacing: CGFloat
    
    init(
        items: [T],
        selectedItem: T?,
        spacing: CGFloat = 12,
        onSelection: @escaping (T) -> Void,
        itemTitle: @escaping (T) -> String
    ) {
        self.items = items
        self.selectedItem = selectedItem
        self.spacing = spacing
        self.onSelection = onSelection
        self.itemTitle = itemTitle
    }
    
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(items, id: \.self) { item in
                SelectableRectangleView(
                    title: itemTitle(item),
                    isSelected: selectedItem == item,
                    selectionMode: .single
                ) {
                    onSelection(item)
                }
            }
        }
    }
}

struct MultipleSelectionList<T: Hashable>: View {
    let items: [T]
    let selectedItems: Set<T>
    let maxSelections: Int?
    let onToggle: (T) -> Void
    let itemTitle: (T) -> String
    let spacing: CGFloat
    
    init(
        items: [T],
        selectedItems: Set<T>,
        maxSelections: Int? = nil,
        spacing: CGFloat = 12,
        onToggle: @escaping (T) -> Void,
        itemTitle: @escaping (T) -> String
    ) {
        self.items = items
        self.selectedItems = selectedItems
        self.maxSelections = maxSelections
        self.spacing = spacing
        self.onToggle = onToggle
        self.itemTitle = itemTitle
    }
    
    private func canSelect(_ item: T) -> Bool {
        if selectedItems.contains(item) { return true }
        guard let max = maxSelections else { return true }
        return selectedItems.count < max
    }
    
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(items, id: \.self) { item in
                let isSelected = selectedItems.contains(item)
                let canSelectItem = canSelect(item)
                
                SelectableRectangleView(
                    title: itemTitle(item),
                    isSelected: isSelected,
                    selectionMode: .multiple
                ) {
                    if canSelectItem {
                        onToggle(item)
                    }
                }
                .opacity(canSelectItem ? 1.0 : 0.6)
                .disabled(!canSelectItem)
            }
        }
    }
}

// MARK: - Generic Selection Manager
class SelectionManager<T: Hashable>: ObservableObject {
    @Published var selectedItems: Set<T> = []
    @Published var singleSelection: T?
    
    let maxSelections: Int?
    let mode: Mode
    
    enum Mode {
        case single
        case multiple(max: Int?)
    }
    
    init(mode: Mode = .single) {
        self.mode = mode
        switch mode {
        case .single:
            self.maxSelections = 1
        case .multiple(let max):
            self.maxSelections = max
        }
    }
    
    func toggle(_ item: T) {
        switch mode {
        case .single:
            singleSelection = singleSelection == item ? nil : item
        case .multiple:
            if selectedItems.contains(item) {
                selectedItems.remove(item)
            } else if canSelect(item) {
                selectedItems.insert(item)
            }
        }
    }
    
    func select(_ item: T) {
        switch mode {
        case .single:
            singleSelection = item
        case .multiple:
            if canSelect(item) {
                selectedItems.insert(item)
            }
        }
    }
    
    func deselect(_ item: T) {
        switch mode {
        case .single:
            if singleSelection == item {
                singleSelection = nil
            }
        case .multiple:
            selectedItems.remove(item)
        }
    }
    
    func isSelected(_ item: T) -> Bool {
        switch mode {
        case .single:
            return singleSelection == item
        case .multiple:
            return selectedItems.contains(item)
        }
    }
    
    private func canSelect(_ item: T) -> Bool {
        if selectedItems.contains(item) { return true }
        guard let max = maxSelections else { return true }
        return selectedItems.count < max
    }
    
    func clear() {
        selectedItems.removeAll()
        singleSelection = nil
    }
    
    var hasSelection: Bool {
        switch mode {
        case .single:
            return singleSelection != nil
        case .multiple:
            return !selectedItems.isEmpty
        }
    }
    
    var selectionCount: Int {
        switch mode {
        case .single:
            return singleSelection != nil ? 1 : 0
        case .multiple:
            return selectedItems.count
        }
    }
}

// MARK: - Usage Examples

// Simple single selection
struct GoalSelectionExample: View {
    @State private var selectedGoal: String? = nil
    
    private let goals = [
        "Job Seeking & Career Growth",
        "Investment",
        "Networking & Relationship Building"
    ]
    
    var body: some View {
        VStack {
            SingleSelectionList(
                items: goals,
                selectedItem: selectedGoal,
                onSelection: { goal in
                    selectedGoal = goal
                },
                itemTitle: { $0 }
            )
        }
        .padding()
    }
}

// Multiple selection with manager
struct InterestsSelectionExample: View {
    @StateObject private var selectionManager = SelectionManager<String>(
        mode: .multiple(max: 3)
    )
    
    private let interests = [
        "Technology", "Finance", "Marketing", "Design"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            MultipleSelectionList(
                items: interests,
                selectedItems: selectionManager.selectedItems,
                maxSelections: 3,
                onToggle: { interest in
                    selectionManager.toggle(interest)
                },
                itemTitle: { $0 }
            )
            
            if selectionManager.hasSelection {
                Text("Selected: \(selectionManager.selectionCount)/3")
                    .font(AppFont.bodySmallMedium)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

// Manual implementation
struct ManualSelectionExample: View {
    @State private var selectedItems: Set<String> = []
    
    private let items = ["Option 1", "Option 2", "Option 3"]
    
    var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                SelectableRectangleView(
                    title: item,
                    isSelected: selectedItems.contains(item),
                    selectionMode: .multiple
                ) {
                    if selectedItems.contains(item) {
                        selectedItems.remove(item)
                    } else {
                        selectedItems.insert(item)
                    }
                }
            }
        }
        .padding()
    }
}

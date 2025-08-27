import SwiftUI
import UIComponentsKit

// MARK: - Button Style Enum
enum CustomButtonStyle {
    case primary
    case secondary
    case newPrimary
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return AppColors.primary
        case .secondary:
            return Color.black
        case .newPrimary:
            return Color.clear // Will use LinearGradient instead
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary:
            return Color.white
        case .secondary:
            return Color.white
        case .newPrimary:
            return Color.white
        }
    }
}

// MARK: - Reusable Button Component
struct CustomButton: View {
    let title: String
    let style: CustomButtonStyle
    let width: CGFloat?
    let action: ()  -> Void
    
    // Optional parameters with default values
    private let height: CGFloat = 44
    private let cornerRadius: CGFloat = 10
    
    init(
        title: String,
        style: CustomButtonStyle,
        width: CGFloat? = nil, // nil means .infinity
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.width = width
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(AppFont.bodySmallSemibold)
                    .foregroundColor(style.textColor)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 15)
            .frame(
                width: width,
                height: height
            )
            .frame(maxWidth: width == nil ? .infinity : width, alignment: .center)
            .background(
                Group {
                    if style == .newPrimary {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.26, green: 0.48, blue: 0.84), location: 0.44),
                                Gradient.Stop(color: Color(red: 0.26, green: 0.66, blue: 0.84), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: -0.03, y: 0),
                            endPoint: UnitPoint(x: 1, y: 1.04)
                        )
                    } else {
                        style.backgroundColor
                    }
                }
            )
            .cornerRadius(style == .newPrimary ? 10 : cornerRadius)
            .shadow(
                color: style == .newPrimary ? .black.opacity(0.1) : .clear,
                radius: style == .newPrimary ? 12.5 : 0,
                x: style == .newPrimary ? 5 : 0,
                y: style == .newPrimary ? 5 : 0
            )
        }
    }
}

// MARK: - Alternative Version with More Customization
struct CustomButtonAdvanced: View {
    let title: String
    let style: CustomButtonStyle
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    let action: () -> Void
    
    init(
        title: String,
        style: CustomButtonStyle,
        width: CGFloat? = nil, // nil means .infinity
        height: CGFloat = 44,
        cornerRadius: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(AppFont.bodySmallRegular)
                    .foregroundColor(style.textColor)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 15)
            .frame(
                width: width,
                height: height
            )
            .frame(maxWidth: width == nil ? .infinity : width, alignment: .center)
            .background(
                Group {
                    if style == .newPrimary {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.26, green: 0.48, blue: 0.84), location: 0.44),
                                Gradient.Stop(color: Color(red: 0.26, green: 0.66, blue: 0.84), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: -0.03, y: 0),
                            endPoint: UnitPoint(x: 1, y: 1.04)
                        )
                    } else {
                        style.backgroundColor
                    }
                }
            )
            .cornerRadius(style == .newPrimary ? 10 : cornerRadius)
            .shadow(
                color: style == .newPrimary ? .black.opacity(0.1) : .clear,
                radius: style == .newPrimary ? 12.5 : 0,
                x: style == .newPrimary ? 5 : 0,
                y: style == .newPrimary ? 5 : 0
            )
        }
    }
}

// MARK: - Usage Examples
struct CustomButtonExamples: View {
    @State private var message = "No button pressed"
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .padding()
            
            // Primary button with fixed width
            CustomButton(
                title: "Scan",
                style: .primary,
                width: 116
            ) {
                message = "Primary button pressed"
            }
            
            // Secondary button with fixed width
            CustomButton(
                title: "Cancel",
                style: .secondary,
                width: 116
            ) {
                message = "Secondary button pressed"
            }
            
            // New Primary button with fixed width
            CustomButton(
                title: "New Primary",
                style: .newPrimary,
                width: 116
            ) {
                message = "New Primary button pressed"
            }
            
            // Primary button with full width (maxWidth: .infinity)
            CustomButton(
                title: "Sign In",
                style: .primary
            ) {
                message = "Full width primary button pressed"
            }
            .padding(.horizontal)
            
            // Secondary button with full width
            CustomButton(
                title: "Create Account",
                style: .secondary
            ) {
                message = "Full width secondary button pressed"
            }
            .padding(.horizontal)
            
            // New Primary button with full width
            CustomButton(
                title: "New Primary Full Width",
                style: .newPrimary
            ) {
                message = "Full width new primary button pressed"
            }
            .padding(.horizontal)
            
            // Using the advanced version with custom height
            CustomButtonAdvanced(
                title: "Custom Height",
                style: .primary,
                width: 200,
                height: 60,
                cornerRadius: 30
            ) {
                message = "Custom height button pressed"
            }
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    CustomButtonExamples()
}

//
//  CustomButton.swift
//  CH-4
//
//  Created by Rafie Amandio F on 24/08/25.
//

import SwiftUI
import UIComponentsKit

// MARK: - Button Style Enum
enum CustomButtonStyle {
    case primary
    case secondary
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return AppColors.primary
        case .secondary:
            return Color.black
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary:
            return Color.white
        case .secondary:
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
    private let cornerRadius: CGFloat = 20
    
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
            Text(title)
                .font(AppFont.bodySmallSemibold)
                .foregroundColor(style.textColor)
                .multilineTextAlignment(.center)
                .frame(
                    width: width,
                    height: height
                )
                .frame(maxWidth: width == nil ? .infinity : width)
                .background(style.backgroundColor)
                .cornerRadius(cornerRadius)
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
            Text(title)
                .font(AppFont.bodySmallRegular)
                .foregroundColor(style.textColor)
                .multilineTextAlignment(.center)
                .frame(
                    width: width,
                    height: height
                )
                .frame(maxWidth: width == nil ? .infinity : width)
                .background(style.backgroundColor)
                .cornerRadius(cornerRadius)
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

//
//  ProgressIndicator.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import SwiftUI

struct ProgressIndicator: View {
    let totalSteps: Int
    let currentStep: Int
    let activeColor: Color
    let inactiveColor: Color
    let spacing: CGFloat
    
    init(
        totalSteps: Int,
        currentStep: Int,
        activeColor: Color = Color(red: 0.2, green: 0.4, blue: 0.8), // Dark blue
        inactiveColor: Color = Color.gray.opacity(0.3), // Light gray
        spacing: CGFloat = 8
    ) {
        self.totalSteps = totalSteps
        self.currentStep = currentStep
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1..<totalSteps + 1, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index <= currentStep ? activeColor : inactiveColor)
                    .frame(height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 3-step progress indicator
        ProgressIndicator(totalSteps: 3, currentStep: 1)
            .padding()
        
        // 4-step progress indicator
        ProgressIndicator(totalSteps: 4, currentStep: 2)
            .padding()
        
        // Custom colors
        ProgressIndicator(
            totalSteps: 5,
            currentStep: 3,
            activeColor: .blue,
            inactiveColor: .gray.opacity(0.2)
        )
        .padding()
    }
}

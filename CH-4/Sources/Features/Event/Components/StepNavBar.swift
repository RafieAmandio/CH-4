//
//  NavBar.swift
//  CH-4
//
//  Created by Phi Phi Pham on 22/8/2025.
//

import SwiftUI
import UIKit

// --- The new navbar component ---
struct StepNavBar: View {
    let title: String
    let totalSteps: Int
    let currentStep: Int

    // Nav button actions + state
    var onBack: () -> Void
    var onNext: () -> Void
    var canGoBack: Bool = true
    var canGoNext: Bool = true

    // Styling (tweak to match your dark theme)
    var barBackground: Color = Color(.sRGB, white: 0.10, opacity: 1) // near-black
    var titleColor: Color = .white
    var iconActive: Color = .white.opacity(0.85)
    var iconDisabled: Color = .white.opacity(0.35)

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(canGoBack ? iconActive : iconDisabled)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .disabled(!canGoBack)

                Spacer()

                Text(title)
                    .font(.system(.title2, weight: .bold))
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(canGoNext ? iconActive : iconDisabled)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .disabled(!canGoNext)
            }

            ProgressIndicator(
                totalSteps: totalSteps,
                currentStep: currentStep,
                activeColor: Color(red: 0.22, green: 0.45, blue: 0.95),
                inactiveColor: .white.opacity(0.35),
                spacing: 16
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(barBackground.ignoresSafeArea(edges: .top))
    }
}

#Preview {
    VStack(spacing: 0) {
        StepNavBar(
            title: "Create Event",
            totalSteps: 3,
            currentStep: 1,
            onBack: {},
            onNext: {},
            canGoBack: false,
            canGoNext: true
        )
        Spacer().background(Color.black.opacity(0.9))
    }
    .background(Color.black.opacity(0.9))
}

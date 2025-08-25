//
//  RefreshButton.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI

struct RefreshButton: View {
    var action: () -> Void
    var title: String = "Refresh"
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
        }
        .background(
            Capsule(style: .circular)
                .fill(Color.blue)
        )
        .padding(.horizontal, 80)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Preview

//
//  CapsuleChip.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI
import UIComponentsKit

struct CapsuleChip: View {
    let title: String
    let systemName: String = "link" // replace with brand asset if you have it
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .imageScale(.medium)
                Text(title)
                    .font(AppFont.bodySmallSemibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(AppColors.TextFieldBackground.opacity(0.8))
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(AppColors.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

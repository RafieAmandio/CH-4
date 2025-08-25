//
//  CardView.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI
import UIComponentsKit

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(AppColors.TextFieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppColors.gray.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

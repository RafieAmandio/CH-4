//
//  ApplyBackground.swift
//  CH-4
//
//  Created by Rafie Amandio F on 24/08/25.
//

import SwiftUI

import UIComponentsKit

struct ApplyBackground<Content:View>: View {
    let content : Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppColors.offBlack)
                .ignoresSafeArea()

            content
        }
    }
}

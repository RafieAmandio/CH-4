//
//  HeaderSectionView.swift
//  CH-4
//
//  Created by Dwiki on 21/08/25.
//

import SwiftUI
import UIComponentsKit

struct HeaderSectionView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Tell us about yourself!")
                .font(AppFont.headingLargeSemiBold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Your information becomes visible to others when you’re suggested to them.")
                .font(AppFont.bodySmallRegular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
    }
}



#Preview {
    HeaderSectionView()
}

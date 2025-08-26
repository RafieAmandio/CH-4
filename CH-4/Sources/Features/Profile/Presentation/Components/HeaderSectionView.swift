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
        VStack(alignment:.leading, spacing: 5) {
            Text("Tell us about yourself!")
                .font(AppFont.inter30Bold)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Text("Your information becomes visible to others when you’re suggested to them.")
                .font(AppFont.inter14Regular)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
        }
        .frame(height: 100)
        .padding(.horizontal, 15)
        .padding(.vertical, 35)
    }
}



#Preview {
    HeaderSectionView()
}

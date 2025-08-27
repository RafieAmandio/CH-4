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
            if #available(iOS 17.0, *) {
                (Text("Tell us about ")
                    .font(AppFont.interLargeSemiBold)
                    + Text("yourself!")
                    .foregroundStyle(LinearGradient.customGradient3)
                    .font(AppFont.interLargeSemiBold))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            } else {
                Text("Tell us about yourself")
                    .font(AppFont.interLargeSemiBold)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            Text("Your information becomes visible to others when you’re suggested to them.")
                .font(AppFont.inter14Regular)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
        }
        .frame(height: 100)
        .padding(.vertical, 35)
    }
}



#Preview {
    HeaderSectionView()
}

//
//  FloatingCardView.swift
//  CH-4
//
//  Created by Dwiki on 26/08/25.
//

import Foundation
import SwiftUI
import UIComponentsKit

struct FloatingCardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("Attend, Discover, Network!")
                .font(AppFont.interLargeBold)
                .foregroundColor(Color(red: 0.1, green: 0.09, blue: 0.1))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Text("Streamline your networking process at events with Findect.")
                .font(
                    AppFont.interMidMedium
                )
                .foregroundColor(Color(red: 0.1, green: 0.09, blue: 0.1))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .opacity(0.3)

            Button {
                viewModel.authenticatedState = .authenticated
                AppStateManager.shared.screen = .appValue
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "apple.logo")
                        .foregroundStyle(.white)
                    Text("Sign Up with Apple")
                        .font(
                            AppFont.interMidBold
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(
                            Color(red: 0.95, green: 0.95, blue: 0.95))
                }
            }
            .withHapticFeedback(.heavy)
            .padding(.horizontal, 0)
            .padding(.vertical, 15)
            .frame(
                maxWidth: .infinity, alignment: .center
            )
            .background(Color(red: 0.1, green: 0.09, blue: 0.1))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 12.5, x: 5, y: 5)

        }
        .padding(20)
        .frame(width: 353, alignment: .center)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -5)
    }

}

#Preview {
    FloatingCardView()
}

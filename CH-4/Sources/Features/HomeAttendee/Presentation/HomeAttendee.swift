//
//  HomeAttendee.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import SwiftUI
import UIComponentsKit

struct HomeAttendee: View {
    @EnvironmentObject var appState: AppStateManager

    var body: some View {
        ApplyBackground {
            VStack (spacing:20) {
                Text("No event right now.Start networking by scanning your QR.")
                    .multilineTextAlignment(.center)
                    .font(AppFont.bodySmallBold)
                    .frame(maxWidth: 296)
                    .foregroundStyle(AppColors.gray)
                
                CustomButton(title: "Scan", style: .primary, width: 116) {
                    print("text")
                }
                
                Button {
                    appState.switchToCreator()
                } label: {
                    Text("Switch Role")
                }
            }
        }

    }
}

#Preview {
    HomeAttendee()
}

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
        NavigationView {
            ApplyBackground {
                VStack(spacing: 20) {
                    Text(
                        "No event right now.Start networking by scanning your QR."
                    )
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

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Event")
                            .font(AppFont.headingMedium)
                          
                        Text("No ongoing event")
                            .font(AppFont.headingSmall)
                            .foregroundColor(.white)
                    }
                    .offset(y:20)
              
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {

                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.white)
                    }
                    .offset(y:20)
                   
                }
            }
        }

    }
}

#Preview {
    HomeAttendee()
}

//
//  HomeView.swift
//  CH-4
//
//  Created by Rafie Amandio F on 31/07/25.
//


import SwiftUI

struct HomeView:  View {
    @StateObject var viewModel = AuthDIContainer.shared.makeAuthViewModel()
    @EnvironmentObject var appState: AppStateManager
    var token = KeychainManager.shared.get(key: "token")

    var body: some View {
        VStack {
            Text(appState.user?.email ?? "No user logged in")
            
            Group {
                switch appState.currentRole {
                case .attendee:
                    Text("Attende")
                case .creator:
                    Text("Creator")
                }
            }
            Button {
                appState.logout()
            } label: {
                Text("Logout")
            }
            
            Button {
                appState.switchRole(to: appState.currentRole == .attendee ? .creator : .attendee)
            } label: {
                Text("Switch Role")
            }

        }
    }
}

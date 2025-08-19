//
//  AuthViewModelContainer.swift
//  CH-4
//
//  Created by Dwiki on 17/08/25.
//

import SwiftUI

struct AuthViewContainer: View {
    @StateObject private var authViewModel = AuthDIContainer.shared.makeAuthViewModel()
    
    @EnvironmentObject private var appState: AppStateManager
    
    var body: some View {
        SignInView(viewModel: authViewModel)
            .onReceive(authViewModel.$authenticatedState) { state in
                handleAuthenticationState(state)
            }
    }
    
    private func handleAuthenticationState(_ state: AuthenticationState) {
        switch state {
        case .authenticated(let user):
            appState.setAuthenticated(true, user: user)
        case .unauthenticated:
            appState.setAuthenticated(false)
        case .loading:
            break
        }
    }
    
    
}

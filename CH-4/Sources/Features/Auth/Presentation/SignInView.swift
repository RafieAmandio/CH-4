//
//  SignIn.swift
//  CH-4
//
//  Created by Dwiki on 11/08/25.
//

import SwiftUI
import AuthenticationServices
import UIComponentsKit

struct SignInView: View {
    @StateObject private var viewModel: AuthViewModel
    @EnvironmentObject private var appState: AppStateManager
    
    init(viewModel: AuthViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            appleSignInView
        }
        .padding()
    }
    
    private var appleSignInView: some View {
        VStack(spacing: 16) {
            Text("Welcome to CH-4")
                .font(AppFont.headingLarge)
                .fontWeight(.bold)
            
            Text("Sign in with your Apple ID to continue")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                Task {
                    await viewModel.handleSignInCompletion(result)
                }
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 50)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView("Signing in...")
                    .padding()
            }
        }
    }
}

#Preview {
    SignInView(viewModel: AuthDIContainer.shared.makeAuthViewModel())
}


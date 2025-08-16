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
    
    init(viewModel: AuthViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isSignedIn {
                signedInView
            } else {
                signInView
            }
        }
        .padding()
        .alert("Sign In Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Signed In View
    private var signedInView: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
            
            Text("Successfully signed in!")
                .font(.headline)
            
            if let user = viewModel.currentUser {
                VStack(spacing: 8) {
                    Text("Welcome, \(user.fullName?.givenName ?? user.email)!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("User ID: \(user.userId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)
            }
            
            Button("Sign Out") {
                Task {
                    await viewModel.signOut()
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoading)
        }
    }
    
    // MARK: - Sign In View
    private var signInView: some View {
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
            .signInWithAppleButtonStyle(.black)
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

// MARK: - Mock Classes for Preview
private class MockAuthRepository: AuthRepositoryProtocol {
    func signInWithApple(idToken: String, nonce: String?) async throws -> User {
        return User(userId: UUID(), email: "mock@example.com", accessToken: "mock-token")
    }
    
    func signOut() async throws {}
    func getCurrentUser() -> User? { return nil }
    func save(_ user: User) throws {}
    func clear() throws {}
}


private class MockSignInWithAppleUseCase: SignInWithAppleUseCaseProtocol {
    func execute(idToken: String, email: String?, fullName: PersonNameComponents?, nonce: String?) async throws -> User {
        return User(userId: UUID(), email: "mock@example.com", accessToken: "mock-token")
    }
}

private class MockSignOutUseCase: SignOutUseCaseProtocol {
    func execute() async throws {}
}

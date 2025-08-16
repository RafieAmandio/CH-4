//
//  AuthViewModel.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
public final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var isSignedIn = false
    @Published var currentUser: User?
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    private let signInWithAppleUseCase: SignInWithAppleUseCaseProtocol
    private let signOutUseCase: SignOutUseCaseProtocol
    private let authRepository: AuthRepositoryProtocol


    // MARK: - Initialization
    public init(
        signInWithAppleUseCase: SignInWithAppleUseCaseProtocol,
        signOutUseCase: SignOutUseCaseProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.signInWithAppleUseCase = signInWithAppleUseCase
        self.signOutUseCase = signOutUseCase
        self.authRepository = authRepository
        
        checkCurrentUser()
    }
    
    // MARK: - Public Methods
    public func handleSignInCompletion(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        showError = false
        
        do {
            let authorization = try result.get()
            
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                throw SignInError.invalidCredential
            }
          
        
            guard let idToken = credential.identityToken,
                  let idTokenString = String(data: idToken, encoding: .utf8) else {
                throw SignInError.invalidToken
            }
            
            guard let authorizationCode = credential.authorizationCode,
                  let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
                throw SignInError.invalidToken
            }
        
            // Execute sign in use case
            let user = try await signInWithAppleUseCase.execute(
                idToken: idTokenString,
                email: credential.email,
                fullName: credential.fullName,
                nonce: nil
            )
            
        
            currentUser = user
            isSignedIn = true
            isLoading = false
            
            print("✅ Successfully signed in with Apple ID: \(credential.user)")
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Sign in failed: \(error)")
        }
    }
    
    public func signOut() async {
        isLoading = true
        
        do {
            try await signOutUseCase.execute()
            
            // Update state
            currentUser = nil
            isSignedIn = false
            isLoading = false
            
            print("✅ Successfully signed out")
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Sign out failed: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func checkCurrentUser() {
        currentUser = authRepository.getCurrentUser()
        isSignedIn = currentUser != nil
    }
}

// MARK: - Error Types
public enum SignInError: LocalizedError {
    case invalidCredential
    case invalidToken
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid Apple ID credential received"
        case .invalidToken:
            return "Invalid identity token received"
        }
    }
}

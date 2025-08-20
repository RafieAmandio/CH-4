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
    @Published var showError = false
    @Published var step = 0
    @Published var errorMessage = ""
    @Published var authenticatedState: AuthenticationState = .unauthenticated
    
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
            
            let accessToken: String = try await signInWithAppleUseCase.execute(credential: credential, nonce: nil )
            
            
            

//            authenticatedState = .authenticated(user)
//    
//            isLoading = false
            
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Sign in failed: \(error)")
        }
    }
}


enum AuthenticationState {
    case loading
    case authenticated(User)
    case unauthenticated
}

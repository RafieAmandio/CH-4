//
//  AuthDIContainer.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation
import NetworkingKit

public final class AuthDIContainer {
    // MARK: - Shared Instance
    public static let shared = AuthDIContainer()
    
    // MARK: - Private Initializer
    private init() {}
    
    
    public lazy var supabaseAuthService: SupabaseAuthServiceProtocol = {
        // You'll need to implement this protocol in your SupabaseAuthService
        SupabaseAuthService()
    }()
    
    // MARK: - Repositories
    public lazy var authRepository: AuthRepositoryProtocol = {
        AuthRepository(
            supabaseAuthService: supabaseAuthService
        )
    }()

    
    // MARK: - Use Cases
    public lazy var signInWithAppleUseCase: SignInWithAppleUseCaseProtocol = {
        SignInWithAppleUseCase(
            repository: authRepository
        )
    }()
    
    public lazy var signOutUseCase: SignOutUseCaseProtocol = {
        SignOutUseCase(authRepository: authRepository)
    }()
    
    public lazy var verifyAndGenerateTokenUseCase: VerifyAndGenerateTokenUseCaseProtocol = {
        VerifyAndGenerateTokenUseCase(repository: authRepository)
    }()
    
    // MARK: - View Models
    @MainActor public func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            signInWithAppleUseCase: signInWithAppleUseCase,
            signOutUseCase: signOutUseCase,
            authRepository: authRepository,
            verifyAndGenerateTokenUseCase: verifyAndGenerateTokenUseCase
        )
    }
}

//
//  SignInWithAppleuseCase.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation

public protocol SignInWithAppleUseCaseProtocol {
    func execute(
        idToken: String,
        email: String?,
        fullName: PersonNameComponents?,
        nonce: String?
    ) async throws -> User
}

public final class SignInWithAppleUseCase: SignInWithAppleUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(
        authRepository: AuthRepositoryProtocol
    ) {
        self.authRepository = authRepository
    }
    
    public func execute(
        idToken: String,
        email: String?,
        fullName: PersonNameComponents?,
        nonce: String?
    ) async throws -> User {
        // Sign in with Apple through the repository
        let user = try await authRepository.signInWithApple(idToken: idToken, nonce: nonce)
        
        // Save user locally
        try authRepository.save(user)
    
        
        return user
    }
}

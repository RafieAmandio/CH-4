//
//  SupabaseAuthService.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation
import Supabase
import NetworkingKit

public protocol SupabaseAuthServiceProtocol {
    func signInWithApple(idToken: String, nonce: String?) async throws -> User
    func signOut() async throws
}

public final class SupabaseAuthService: SupabaseAuthServiceProtocol {
    private let supabaseProvider: DefaultSupabaseClientProvider
    
    public init() {
        self.supabaseProvider = DefaultSupabaseClientProvider(
            url: URL(string: AppConfig.supabaseURL)!,
            anonKey: AppConfig.supabaseAnonKey
        )
    }
    
    // MARK: - SupabaseAuthServiceProtocol Implementation
    
    public func signInWithApple(idToken: String, nonce: String?) async throws -> User {
        let response = try await supabaseProvider.client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )
        let user = response.user
        
        KeychainManager.shared.save(token: response.accessToken, for: "token")
        
        return User(
            userId: user.id,
            email: user.email ?? ""
        )
    }
    
    public func signOut() async throws {
        try await supabaseProvider.client.auth.signOut()
    }
}

// MARK: - Models


// MARK: - Errors
public enum SupabaseAuthError: LocalizedError {
    // Add other auth-related errors here as needed
    
    public var errorDescription: String? {
        switch self {
        // Handle other error cases here
        }
    }
}

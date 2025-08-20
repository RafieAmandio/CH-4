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
    func signInWithApple(idToken: String, nonce: String?) async throws -> String
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
    
    public func signInWithApple(idToken: String, nonce: String?) async throws -> String {
        let response = try await supabaseProvider.client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )
    
        return response.accessToken
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

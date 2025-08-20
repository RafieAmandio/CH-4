//
//  AuthRepository.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation

public final class AuthRepository: AuthRepositoryProtocol {
    private let supabaseAuthService: SupabaseAuthServiceProtocol
    
    private let userDefaults = UserDefaults.standard
    
    private let userKey = "user"
    
    public init(
        supabaseAuthService: SupabaseAuthServiceProtocol
    ) {
        self.supabaseAuthService = supabaseAuthService
    }
    
    // MARK: - AuthRepositoryProtocol Implementation
    
    public func signInWithApple(idToken: String, nonce: String?) async throws -> String {
        // Sign in with Supabase
        let accessToken = try await supabaseAuthService.signInWithApple(idToken: idToken, nonce: nonce)
        
        return accessToken
    }
    
    public func signOut() async throws {
        try await supabaseAuthService.signOut()
    }
    
    public func getCurrentUser() -> User? {
        guard let data = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    public func save(_ user: User) throws {
        let data = try JSONEncoder().encode(user)
        userDefaults.set(data, forKey: userKey)
    }
    
    public func clear() throws {
        userDefaults.removeObject(forKey: userKey)
    }
}

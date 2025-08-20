//
//  AuthRepositoryProtocol.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation

public protocol AuthRepositoryProtocol {
    func signInWithApple(idToken: String, nonce: String?) async throws -> String
    func signOut() async throws
    func verifyAndGenerateToken() async throws -> LoginResponse
    func getCurrentUser() -> UserData?
    func save(_ user: UserData) throws
    func clear() throws
}

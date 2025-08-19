//
//  AuthRepositoryProtocol.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation

public protocol AuthRepositoryProtocol {
    func signInWithApple(idToken: String, nonce: String?) async throws -> User
    func signOut() async throws
    func getCurrentUser() -> User?
    func save(_ user: User) throws
    func clear() throws
}

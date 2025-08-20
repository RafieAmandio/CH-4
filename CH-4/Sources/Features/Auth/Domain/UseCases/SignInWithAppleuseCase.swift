//
//  SignInWithAppleuseCase.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation
import AuthenticationServices

public protocol SignInWithAppleUseCaseProtocol {
    func execute(credential: ASAuthorizationAppleIDCredential, nonce: String?) async throws -> String
}

public class SignInWithAppleUseCase: SignInWithAppleUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(credential: ASAuthorizationAppleIDCredential, nonce: String?) async throws -> String {
        guard let idToken = credential.identityToken,
              let idTokenString = String(data: idToken, encoding: .utf8) else {
            throw SignInError.invalidToken
        }
        
        guard let token = credential.authorizationCode,
              let tokenString = String(data: token, encoding: .utf8) else {
            throw SignInError.invalidToken
        }
    
   
        let accessToken = try await repository.signInWithApple(
            idToken: idTokenString,
            nonce: nil
        )
        
        
        
    }
    
}


public enum SignInError: LocalizedError {
    case invalidCredential
    case invalidToken
    case malformedToken
    case networkError
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid Apple ID credential received"
        case .invalidToken:
            return "Invalid identity token received"
        case .malformedToken:
            return "Token format is invalid"
        case .networkError:
            return "Network connection failed"
        }
    }
}

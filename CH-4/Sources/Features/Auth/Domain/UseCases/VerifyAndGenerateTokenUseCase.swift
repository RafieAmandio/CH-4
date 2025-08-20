//
//  VerifyAndGenerateToken.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public protocol VerifyAndGenerateTokenUseCaseProtocol {
    func execute() async throws -> UserData
}


public class VerifyAndGenerateTokenUseCase:VerifyAndGenerateTokenUseCaseProtocol{
    
    private let repository: AuthRepositoryProtocol
    
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> UserData {
        let user = try await repository.verifyAndGenerateToken()
      
        let _ =  KeychainManager.shared.save(token: user.token, for: "access_token")

        try repository.save(user.user)
        
        return user.user
    }
}

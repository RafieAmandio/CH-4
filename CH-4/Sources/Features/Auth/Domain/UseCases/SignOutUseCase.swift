//
//  SignOutUseCase.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation

public protocol SignOutUseCaseProtocol {
    func execute() async throws
}

public final class SignOutUseCase: SignOutUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute() async throws {
        try await authRepository.signOut()
        try authRepository.clear()
    }
}

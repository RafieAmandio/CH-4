//
//  CreateEventUseCase.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public protocol UpdateProfileUseCaseProtocol {
    func execute(payload: UpdateProfilePayload) async throws -> CreateOrUpdateResult
}

public final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {

    private let userRepository: UserRepositoryProtocol

    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    public func execute(payload: UpdateProfilePayload) async throws -> CreateOrUpdateResult {
        let response = try await userRepository.completeProfile(with: payload)
        
        return CreateOrUpdateResult(success: true, message: "string", errors: [])
        
    }
}

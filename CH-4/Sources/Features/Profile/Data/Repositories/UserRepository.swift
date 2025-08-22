//
//  UserRepository.swift
//  CH-4
//
//  Created by Dwiki on 21/08/25.
//

import Foundation

public protocol UserRepositoryProtocol {
    func fetchProfessions() async throws -> FetchProfessionsResponse
    func completeProfile(with request: UpdateProfilePayload) async throws -> CreateOrUpdateResult
}

public final class UserRepository: UserRepositoryProtocol {
    private let ProfileAPIService: ProfileAPIServiceProtocol
    
    public init(ProfileAPIService: ProfileAPIServiceProtocol) {
        self.ProfileAPIService = ProfileAPIService
    }
    public func fetchProfessions() async throws -> FetchProfessionsResponse {
        let response = try await ProfileAPIService.fetchProfessions()
        
        return response
    }
    
    public func completeProfile(with request: UpdateProfilePayload) async throws -> CreateOrUpdateResult {
        let response = try await ProfileAPIService.completeProfile(payload: request)

        return response
    }
}

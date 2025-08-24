//
//  FetchRecommendationsUseCase.swift
//  CH-4
//
//  Created by Dwiki on 25/08/25.
//

import Foundation

public protocol FetchRecommendationsUseCaseProtocol {
    func execute() async throws -> RecommendationResponse
}

public class FetchRecommendationsUseCase: FetchRecommendationsUseCaseProtocol {
    private let repository: AttendeeRepositoryProtocol
    
    public init(repository: AttendeeRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> RecommendationResponse {
        return try await repository.fetchRecommendations()
    }
}

// MARK: - Repository Protocol


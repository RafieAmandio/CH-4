//
//  EventRepository.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import Foundation

public protocol AttendeeRepositoryProtocol {
    func fetchGoals() async throws -> [GoalsCategory]
    func registerAttende(with payload: RegisterAttendeePayload) async throws
        -> RegisterAttendeeResponse
    
    func submitGoal(with payload: SubmitGoalPayload) async throws -> SubmitGoalResponse
    
    func submitAnswer(with payload: AnswerSubmissionRequest) async throws -> SubmitAnswerResponse
    
    func fetchRecommendations() async throws -> RecommendationResponse
}

public final class AttendeeRepository: AttendeeRepositoryProtocol {
    private let attendeeAPIService: AttendeeAPIServiceProtocol

    public init(attendeeAPIService: AttendeeAPIServiceProtocol) {
        self.attendeeAPIService = attendeeAPIService
    }

    public func fetchGoals() async throws -> [GoalsCategory] {
        let event = try await attendeeAPIService.fetchGoals()

        return event
    }

    public func registerAttende(with payload: RegisterAttendeePayload)
        async throws -> RegisterAttendeeResponse
    {
        return try await attendeeAPIService.registerAttendee(with: payload)
    }
    
    public func submitGoal(with payload: SubmitGoalPayload)
    async throws -> SubmitGoalResponse
    {
        return try await attendeeAPIService.submitGoals(with: payload)
    }
    
    public func submitAnswer(with payload: AnswerSubmissionRequest) async throws -> SubmitAnswerResponse {
        return try await attendeeAPIService.submitAnswer(with: payload)
    }
    
    public func fetchRecommendations() async throws -> RecommendationResponse {
        return try await attendeeAPIService.fetchRecommendation()
    }
}

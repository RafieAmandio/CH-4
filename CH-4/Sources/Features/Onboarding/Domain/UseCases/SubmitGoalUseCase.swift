//
//  SubmitGoalUseCase.swift
//  CH-4
//
//  Created by Dwiki on 23/08/25.
//

import Foundation

public protocol SubmitGoalUseCaseProtocol {
    func execute(with payload: SubmitGoalPayload)  async throws -> SubmitGoalResponse
}


public final class SubmitGoalUseCase: SubmitGoalUseCaseProtocol {
    private let attendeRepository: AttendeeRepositoryProtocol

    public init(attendeRepository: AttendeeRepositoryProtocol) {
        self.attendeRepository = attendeRepository
    }

    
    public func execute(with payload: SubmitGoalPayload) async throws -> SubmitGoalResponse {
        let result = try await  attendeRepository.submitGoal(with: payload)
        return result
    }
}

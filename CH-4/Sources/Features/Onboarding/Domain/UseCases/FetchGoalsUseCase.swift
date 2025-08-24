//
//  CreateEventUseCase.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public protocol FetchGoalsUseCaseProtocol {
    func execute() async throws -> [GoalsCategory]
}

public final class FetchGoalsUseCase: FetchGoalsUseCaseProtocol {

    private let attendeRepository: AttendeeRepositoryProtocol

    public init(attendeRepository: AttendeeRepositoryProtocol) {
        self.attendeRepository = attendeRepository
    }

    public func execute() async throws -> [GoalsCategory] {

        let goals: [GoalsCategory] = try await attendeRepository.fetchGoals()
        
        return goals
    }
}

//
//  EventRepository.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import Foundation

public protocol AttendeeRepositoryProtocol {
    func fetchGoals() async throws -> [GoalsCategory]
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
}

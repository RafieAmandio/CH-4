//
//  CreateEventUseCase.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public protocol CreateEventUseCaseProtocol {
    func execute(event: EventCreationForm) async throws -> CreateOrUpdateResult
}

public final class CreateEventUseCase: CreateEventUseCaseProtocol {

    private let eventRepository: EventRepositoryProtocol

    public init(eventRepository: EventRepositoryProtocol) {
        self.eventRepository = eventRepository
    }

    public func execute(event: EventCreationForm) async throws -> CreateOrUpdateResult {
        let dtoPayload = EventCreationPayload(
            name: event.name,
            description: event.description,
            datetime: ISO8601DateFormatter().string(from: event.dateTime),
            location: event.location.name,
            latitude: event.location.coordinate.latitude,
            longitude: event.location.coordinate.longitude
        )
        
        let result = try await eventRepository.createEvent(dtoPayload)

        return result
    }
}

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
        let dateFormatter = ISO8601DateFormatter()
        
        let dtoPayload = EventCreationPayload(
            name: event.name,
            start: dateFormatter.string(from: event.startDateTime),
            end: dateFormatter.string(from: event.endDateTime),
            description: event.description.isEmpty ? nil : event.description,
            photoLink: event.photoLink,
            locationName: event.location.name.isEmpty ? nil : event.location.name,
            locationAddress: nil, // TODO: Get from location if available
            locationLink: nil, // TODO: Get from location if available
            latitude: event.location.coordinate.latitude == 0 ? nil : event.location.coordinate.latitude,
            longitude: event.location.coordinate.longitude == 0 ? nil : event.location.coordinate.longitude,
            link: nil // TODO: Add event link if needed
        )
        
        let result = try await eventRepository.createEvent(dtoPayload)

        return result
    }
}

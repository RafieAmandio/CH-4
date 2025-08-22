//
//  EventRepository.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import Foundation

public protocol EventRepositoryProtocol {
    func createEvent(_ input : EventCreationPayload) async throws -> CreateOrUpdateResult
}

public final class EventRepository: EventRepositoryProtocol {
    private let eventAPIService: EventAPIServiceProtocol
    
    public init(eventAPIService: EventAPIServiceProtocol) {
        self.eventAPIService = eventAPIService
    }
    
    public func createEvent(_ input: EventCreationPayload) async throws -> CreateOrUpdateResult {
        let event = try await eventAPIService.createEvent(payload: input)
        
        return event
    }
}

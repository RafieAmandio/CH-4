//
//  CreateEventUseCase.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public protocol ValidateEventUseCaseProtocol {
    func execute(code: String) async throws -> EventValidateModel
}

public final class ValidateEventUseCase: ValidateEventUseCaseProtocol {

    private let eventRepository: EventRepositoryProtocol

    public init(eventRepository: EventRepositoryProtocol) {
        self.eventRepository = eventRepository
    }

    public func execute(code: String) async throws -> EventValidateModel {
  
        let result = try await eventRepository.validateEvent(with: code)

        return EventValidateModel(name: result.data.name, photoLink: result.data.photoLink ?? "", currentParticipant: result.data.currentParticipants , code: result.data.code, endDate: result.data.end)
    }
}

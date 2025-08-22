//
//  AuthDIContainer.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation
import NetworkingKit

public final class HomeAttendeeDIContainer {
    // MARK: - Shared Instance
    public static let shared = HomeAttendeeDIContainer()

    // MARK: - Private Initializer
    private init() {}

    public lazy var eventRepository: EventRepositoryProtocol = {
        EventRepository(eventAPIService: eventAPIService)
    }()

    public lazy var eventAPIService: EventAPIServiceProtocol = {
        EventAPIService(apiClient: APIClient.shared)
    }()

    // MARK: - Use Cases
    public lazy var  validateEventUseCase:
    ValidateEventUseCaseProtocol = {
        ValidateEventUseCase(eventRepository: eventRepository)
        }()

    // MARK: - View Models
    @MainActor public func createHomeAttendeeViewModel() -> HomeAttendeeViewModel {
        HomeAttendeeViewModel(validateEventUseCase: validateEventUseCase)
    }
}

//
//  AuthDIContainer.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation
import NetworkingKit

public final class EventDIContainer {
    // MARK: - Shared Instance
    public static let shared = EventDIContainer()
    
    // MARK: - Private Initializer
    private init() {}
    
    public lazy var eventAPIService: EventAPIServiceProtocol = {
        EventAPIService(apiClient: APIClient.shared )
    }()
    
    public lazy var eventRepository: EventRepositoryProtocol = {
        EventRepository(eventAPIService: eventAPIService )
    }()
    
    
    
    
    // MARK: - Use Cases
    public lazy var createEventUseCase: CreateEventUseCaseProtocol = {
        CreateEventUseCase(eventRepository: eventRepository)
    }()
    

    
    // MARK: - View Models
    @MainActor public func createEventViewModel() -> CreateEventViewModel {
        CreateEventViewModel(createEventUseCase: createEventUseCase)
    }
}

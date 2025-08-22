//
//  AuthDIContainer.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation
import NetworkingKit

public final class OnBoardingDIContainer {
    // MARK: - Shared Instance
    public static let shared = OnBoardingDIContainer()
    
    // MARK: - Private Initializer
    private init() {}

    
    // MARK: - Repositories
    public lazy var attendeeRepository: AttendeeRepositoryProtocol = {
        AttendeeRepository(attendeeAPIService: attendeeAPIService)
    }()
    
    public lazy var apiClient: APIClientProtocol = {
        APIClient.shared
    }()
    
    public lazy var attendeeAPIService: AttendeeAPIService = {
        AttendeeAPIService(apiClient: apiClient)
    }()

    
    // MARK: - Use Cases
  
    

    public lazy var fetchGoals: FetchGoalsUseCaseProtocol = {
        FetchGoalsUseCase(attendeRepository: attendeeRepository)
    }()
    
    // MARK: - View Models
    @MainActor public func makeOnBoardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(fetchGoalsUseCase: fetchGoals)
    }
}

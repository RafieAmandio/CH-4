//
//  AuthDIContainer.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation
import NetworkingKit

public final class ProfileDIContainer {
    // MARK: - Shared Instance
    public static let shared = ProfileDIContainer()

    // MARK: - Private Initializer
    private init() {}

    public lazy var profileAPIService: ProfileAPIServiceProtocol = {
        ProfileAPIService(apiClient: APIClient.shared)
    }()
    

    public lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(ProfileAPIService: profileAPIService)
    }()

    // MARK: - Use Cases
    public lazy var fetchProfessionListUseCase:
        FetchProfessionListUseCaseProtocol = {
            FetchProfessionListUseCase(userRepository: userRepository)
        }()
    
    public lazy var updateProfileUseCase:
    UpdateProfileUseCaseProtocol = {
        UpdateProfileUseCase(userRepository: userRepository)
        }()
    

    // MARK: - View Models
    @MainActor public func createProfileViewModel() -> UpdateProfileViewModel {
        UpdateProfileViewModel(
            fetchProfessionListUseCase: fetchProfessionListUseCase,
            updateProfileUseCase: updateProfileUseCase)
    }
}

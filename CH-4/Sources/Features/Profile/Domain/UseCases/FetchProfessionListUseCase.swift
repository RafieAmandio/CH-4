//
//  CreateEventUseCase.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public protocol FetchProfessionListUseCaseProtocol {
    func execute() async throws -> [ProfessionModel]
}

public final class FetchProfessionListUseCase: FetchProfessionListUseCaseProtocol {

    private let userRepository: UserRepositoryProtocol

    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    public func execute() async throws -> [ProfessionModel] {
        let response = try await userRepository.fetchProfessions()

        return response.data.flatMap { category in
                category.professions.map { profession in
                    ProfessionModel(
                        id: profession.id,
                        name: profession.name
                    )
                }
            }
    }
}

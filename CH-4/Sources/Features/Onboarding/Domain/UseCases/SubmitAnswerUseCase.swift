//
//  SubmitAnswerUseCase.swift
//  CH-4
//
//  Created by Dwiki on 24/08/25.
//

public protocol SubmitAnswerUseCaseProtocol {
    func execute(with payload: AnswerSubmissionRequest) async throws
        -> SubmitAnswerResponse
}

public final class SubmitAnswerUseCase: SubmitAnswerUseCaseProtocol {
    private let attendeRepository: AttendeeRepositoryProtocol

    public init(attendeRepository: AttendeeRepositoryProtocol) {
        self.attendeRepository = attendeRepository
    }

    public func execute(with payload: AnswerSubmissionRequest) async throws
        -> SubmitAnswerResponse
    {
        return try await attendeRepository.submitAnswer(with: payload)
    }
}

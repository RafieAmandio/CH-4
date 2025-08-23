//
//  CreateEventUseCase.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public protocol RegisterAttendeeUseCaseProtocol {
    func execute(with payload: RegisterAttendeePayload) async throws -> AttendeeRegisterModel
}

public final class RegisterAttendeeUseCase: RegisterAttendeeUseCaseProtocol {
    
    private let attendeeRepository: AttendeeRepositoryProtocol
    
    public init(attendeeRepository: AttendeeRepositoryProtocol) {
        self.attendeeRepository = attendeeRepository
    }
    
    public func execute(with payload: RegisterAttendeePayload) async throws -> AttendeeRegisterModel {
        
        let result = try await attendeeRepository.registerAttende(with: payload)
        
        guard
            let data = result.data,
            let attendeeId = data.attendeeId,
            let accessToken = data.accessToken
        else {
            throw APIError.noData
        }
        
        return AttendeeRegisterModel(
            success: true,
            attendeeId: attendeeId,
            accessToken: accessToken,
            message: result.message
        )
        
    }
}

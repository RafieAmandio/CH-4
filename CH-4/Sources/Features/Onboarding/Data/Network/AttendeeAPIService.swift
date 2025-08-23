// EventData/Sources/Network/EventAPIService.swift
import Foundation

public protocol AttendeeAPIServiceProtocol {
    func fetchGoals() async throws -> [GoalsCategory]
    func registerAttendee(with payload: RegisterAttendeePayload) async throws -> RegisterAttendeeResponse
    func submitGoals(with payload: SubmitGoalPayload) async throws -> SubmitGoalResponse
}

public final class AttendeeAPIService: AttendeeAPIServiceProtocol {

    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    public func fetchGoals() async throws -> [GoalsCategory] {
        let apiResponse: APIResponse<[GoalsCategory]> =
            try await apiClient.requestWithAPIResponse(
                endpoint: .fetchGoals(),
                responseType: [GoalsCategory].self
            )
        
        return apiResponse.data ?? []
    }
    
    public func submitGoals(with payload: SubmitGoalPayload) async throws -> SubmitGoalResponse {
        let apiResponse: APIResponse<SubmitGoalResponseDTO> =
        try await apiClient.requestWithAPIResponse(
            endpoint: .submitGoals(payload),
            responseType: SubmitGoalResponseDTO.self
        )
        
        guard let data = apiResponse.data else {
            throw APIError.noData
        }
        
        return SubmitGoalResponse( data: data, message: apiResponse.message, error: apiResponse.errors)
    }
    
    public func registerAttendee(with payload: RegisterAttendeePayload) async throws -> RegisterAttendeeResponse {
        let apiResponse: APIResponse<RegisterAttendeeDTO> =
        try await apiClient.requestWithAPIResponse(
            endpoint: .registerAttendee(payload),
            responseType: RegisterAttendeeDTO.self
        )
        
        guard let data = apiResponse.data else {
            throw APIError.noData
        }
        
        return RegisterAttendeeResponse(message: apiResponse.message, data: apiResponse.data, errors: apiResponse.errors)
    }
}

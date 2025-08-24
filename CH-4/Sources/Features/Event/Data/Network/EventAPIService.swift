// EventData/Sources/Network/EventAPIService.swift
import Foundation

public protocol EventAPIServiceProtocol {
    func createEvent(payload: EventCreationPayload) async throws
    -> CreateOrUpdateResult
    
    func validateEvent(with code: String) async throws -> ValidateEventResponse
}

public final class EventAPIService: EventAPIServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    public func createEvent(payload: EventCreationPayload) async throws
        -> CreateOrUpdateResult
    {
        let apiResponse: APIResponse<EventData> =
            try await apiClient.requestWithAPIResponse(
                endpoint: .createEvent(payload),
                responseType: EventData.self
            )

        return CreateOrUpdateResult(success: apiResponse.success, message: apiResponse.message, errors: apiResponse.errors)
    }
    
    public func validateEvent(with code: String) async throws -> ValidateEventResponse {
        let apiResponse: APIResponse<EventDetailDTO> =
        try await apiClient.requestWithAPIResponse(
            endpoint: .validateEvent(code),
            responseType: EventDetailDTO.self
        )
        
        guard let eventData = apiResponse.data else {
            throw APIError.noData
        }
        
        return ValidateEventResponse(success: apiResponse
            .success, message: apiResponse.message, data: eventData, errors: apiResponse.errors)
    }
}

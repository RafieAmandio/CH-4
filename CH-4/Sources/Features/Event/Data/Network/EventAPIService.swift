// EventData/Sources/Network/EventAPIService.swift
import Foundation
import UIKit

public protocol EventAPIServiceProtocol {
    func createEvent(payload: EventCreationPayload) async throws
        -> CreateEventResult
}

public final class EventAPIService: EventAPIServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    public func createEvent(payload: EventCreationPayload) async throws
        -> CreateEventResult
    {
        let apiResponse: APIResponse<EventData> =
            try await apiClient.requestWithAPIResponse(
                endpoint: .createEvent(payload),
                responseType: EventData.self
            )

        return CreateEventResult(success: apiResponse.success, message: apiResponse.message, errors: apiResponse.errors)
    }
}

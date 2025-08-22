// EventData/Sources/Network/EventAPIService.swift
import Foundation

public protocol AttendeeAPIServiceProtocol {
    func fetchGoals() async throws -> [GoalsCategory]
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
}

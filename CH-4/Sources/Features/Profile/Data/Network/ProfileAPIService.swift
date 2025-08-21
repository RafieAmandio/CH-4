// EventData/Sources/Network/EventAPIService.swift
import Foundation

public protocol ProfileAPIServiceProtocol {
    func updateProfile(payload: UpdateProfilePayload) async throws
        -> CreateOrUpdateResult
}

public final class ProfileAPIService: ProfileAPIServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    public func updateProfile(payload: UpdateProfilePayload) async throws
        -> CreateOrUpdateResult
    {
        let apiResponse: APIResponse<UpdatedData> =
            try await apiClient.requestWithAPIResponse(
                endpoint: .updateProfile(payload),
                responseType: UpdatedData.self
            )

        return CreateOrUpdateResult(
            success: apiResponse.success, message: apiResponse.message,
            errors: apiResponse.errors)
    }
}

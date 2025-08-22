// EventData/Sources/Network/EventAPIService.swift
import Foundation

public protocol ProfileAPIServiceProtocol {
    func completeProfile(payload: UpdateProfilePayload) async throws
        -> CreateOrUpdateResult

    func fetchProfessions() async throws -> FetchProfessionsResponse
}

public final class ProfileAPIService: ProfileAPIServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    public func completeProfile(payload: UpdateProfilePayload) async throws
        -> CreateOrUpdateResult
    {
        let apiResponse: APIResponse<UpdateProfileResponseDTO> =
            try await apiClient.requestWithAPIResponse(
                endpoint: .completeProfile(payload),
                responseType: UpdateProfileResponseDTO.self
            )
        
        print(apiResponse,"apiresponse")

        return CreateOrUpdateResult(
            success: apiResponse.success, message: apiResponse.message,
            errors: apiResponse.errors)
    }

    public func fetchProfessions() async throws -> FetchProfessionsResponse {
        let apiResponse: APIResponse<[ProfessionListDTO]> =
            try await apiClient.requestWithAPIResponse(
                endpoint: .fetchProfessions(),
                responseType: [ProfessionListDTO].self
            )

        return FetchProfessionsResponse(
            success: apiResponse.success,
            message: apiResponse.message,
            data: apiResponse.data ?? [],
            errors: apiResponse.errors
        )
    }
}

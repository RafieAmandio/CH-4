//
//  BackendService.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.

import Foundation

public protocol AuthAPIServiceProtocol {
    func generateToken() async throws -> LoginResponse
}

public final class AuthAPIService: AuthAPIServiceProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    public func generateToken() async throws
    -> LoginResponse
    {
        let response:  APIResponse<LoginResponse> = try await apiClient.requestWithAPIResponse(endpoint: .login(), responseType: LoginResponse.self)
        
        guard let loginResponse = response.data else {
            throw APIError.invalidURL
        }
        
        print(loginResponse,"LOGINRESPOSE")
        return loginResponse
        
    }
}

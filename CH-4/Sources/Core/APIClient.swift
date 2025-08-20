//
//  ApiClient.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

// MARK: - API Client Protocol
public protocol APIClientProtocol {

    func requestWithAPIResponse<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> APIResponse<T>
}

// MARK: - Main API Client
public class APIClient: APIClientProtocol {
    public static let shared = APIClient()

    private let session: URLSession
    private let baseURL: String
    private var keychainManager: KeychainManager

    private enum TokenKeys {
        static let accessToken = "access_token"
    }

    // Configuration
    struct Configuration {
        let baseURL: String
        let timeoutInterval: TimeInterval
        let cachePolicy: URLRequest.CachePolicy

        static let `default` = Configuration(
            baseURL: AppConfig.backendBaseURL,
            timeoutInterval: 30,
            cachePolicy: .useProtocolCachePolicy
        )
    }

    private let configuration: Configuration

    init(
        configuration: Configuration = .default,
        keychainManager: KeychainManager = .shared
    ) {
        self.configuration = configuration
        self.baseURL = configuration.baseURL
        self.keychainManager = keychainManager

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.timeoutInterval
        config.requestCachePolicy = configuration.cachePolicy
        self.session = URLSession(configuration: config)
    }

    func clearAuthToken() {
        _ = keychainManager.delete(key: TokenKeys.accessToken)
    }

    // MARK: - Authentication
    func setAuthToken(_ token: String) {
        _ = keychainManager.save(token: token, for: TokenKeys.accessToken)
    }

    private var authToken: String? {
        return keychainManager.get(key: TokenKeys.accessToken)
    }

    // MARK: - Main Requ

    public func requestWithAPIResponse<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> APIResponse<T> {
        let request = try buildRequest(for: endpoint)

        do {
            let (data, response) = try await session.data(for: request)
            
            // Print raw data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw API Response:", jsonString)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                try handleHTTPResponse(httpResponse, data: data)
            }

            let apiResponse = try Decoders.api.decode(APIResponse<T>.self, from: data)

            return apiResponse

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
    

    // MARK: - Request Builder
    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        var urlComponents = URLComponents(
            url: url, resolvingAgainstBaseURL: false)

        // Add query parameters
        if !endpoint.queryParameters.isEmpty {
            urlComponents?.queryItems = endpoint.queryParameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }

        guard let finalURL = urlComponents?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = configuration.cachePolicy
        request.timeoutInterval = configuration.timeoutInterval

        // Add headers
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add authorization header
        if let token = authToken {
            request.setValue(
                "Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body for POST, PUT, PATCH requests
        if let body = endpoint.body {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body)
                let jsonString = String(data: jsonData, encoding: .utf8)
                request.httpBody = jsonData
                request.setValue(
                    "application/json", forHTTPHeaderField: "Content-Type")

            } catch {
                throw APIError.encodingError
            }
        } else {
            print("�� No request body")
        }

        return request
    }

    // MARK: - Response Handler
    private func handleHTTPResponse(_ response: HTTPURLResponse, data: Data)
        throws
    {
        switch response.statusCode {
        case 200...299:
    
            // Success - do nothing
            break
        case 401:
            // Try to parse error response for more details
            if let errorResponse = try? JSONDecoder().decode(
                APIErrorResponse.self, from: data)
            {
                throw APIError.unauthorized(
                    errorResponse.message ?? "Unauthorized")
            } else {
                throw APIError.unauthorized("Authentication required")
            }
        case 400..<404:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 422:
            // Validation errors
            if let errorResponse = try? JSONDecoder().decode(
                APIErrorResponse.self, from: data)
            {
                throw APIError.validationError(errorResponse.errors ?? [])
            } else {
                throw APIError.validationError(["Validation failed"])
            }
        case 500...599:
            throw APIError.serverError(response.statusCode)
        default:
            throw APIError.unknownError(response.statusCode)
        }
    }
}

// MARK: - API Response Models
public struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T?
    let errors: [APIErrorItem]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decode(String.self, forKey: .message)
        data = try container.decodeIfPresent(T.self, forKey: .data)
        errors = try container.decodeIfPresent([APIErrorItem].self, forKey: .errors) ?? []
    }
}


public struct APIErrorItem: Codable, CustomStringConvertible {
    public let field: String?
    public let message: String

    public var description: String {
        if let f = field, !f.isEmpty { return "\(f): \(message)" }
        return message
    }
}

struct APIErrorResponse: Codable {
    let success: Bool
    let message: String?
    let errors: [String]?
}

// MARK: - API Endpoints
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case networkError(String)
    case unauthorized(String)
    case forbidden
    case notFound
    case validationError([String])
    case serverError(Int)
    case unknownError(Int)
    case apiError(String)
    case noData
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Failed to encode request"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .validationError(let errors):
            return "Validation failed: \(errors.joined(separator: ", "))"
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknownError(let code):
            return "Unknown error (\(code))"
        case .apiError(let message):
            return message
        case .noData:
            return "No data received"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        }
    }
}


enum Decoders {
    static let api: JSONDecoder = {
        let d = JSONDecoder()
        // You already use explicit CodingKeys, so default keys are fine:
        d.keyDecodingStrategy = .useDefaultKeys

        let isoFrac = ISO8601DateFormatter()
        isoFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]

        d.dateDecodingStrategy = .custom { dec in
            let s = try dec.singleValueContainer().decode(String.self)
            if let dt = isoFrac.date(from: s) ?? iso.date(from: s) {
                return dt
            }
            throw DecodingError.dataCorruptedError(
                in: try dec.singleValueContainer(),
                debugDescription: "Unrecognized ISO8601 date: \(s)"
            )
        }
        return d
    }()
}

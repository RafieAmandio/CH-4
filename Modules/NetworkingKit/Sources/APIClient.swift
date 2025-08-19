// APIClient.swift
import Foundation

public protocol APIClientType {
    func send<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response
}

public enum APIClientError: LocalizedError {
    case invalidURL
    case transport(Error)
    case badStatus(code: Int, data: Data?)
    case decoding(Error, data: Data?)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .transport(let e): return "Network error: \(e.localizedDescription)"
        case .badStatus(let code, _): return "Bad status code: \(code)"
        case .decoding(let e, _): return "Decoding error: \(e.localizedDescription)"
        }
    }
}

public final class APIClient: APIClientType {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(baseURL: URL, session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    public func send<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else { throw APIClientError.invalidURL }

        components.queryItems = endpoint.query.isEmpty ? nil : endpoint.query
        guard let url = components.url else { throw APIClientError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        do {
            let (data, response) = try await session.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200..<300).contains(status) else {
                throw APIClientError.badStatus(code: status, data: data)
            }

            // If Response == EmptyResponse and data is empty/whitespace, decode safely
            if Response.self == EmptyResponse.self, data.isEmpty {
                // Force-cast is safe because we checked the type
                return EmptyResponse() as! Response
            }

            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw APIClientError.decoding(error, data: data)
            }
        } catch {
            throw APIClientError.transport(error)
        }
    }
}

//
//  APIClient.swift
//  CH-4
//
//  Created by Dwiki on 08/08/25.
//

// APIClient.swift
import Foundation

public protocol APIClientType {
  func send<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response
}

public final class APIClient: APIClientType {
  private let baseURL: URL
  private let session: URLSession

  public init(baseURL: URL, session: URLSession = .shared) {
    self.baseURL = baseURL
    self.session = session
  }

  public func send<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response {
    var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
                                   resolvingAgainstBaseURL: false)!
    components.queryItems = endpoint.query.isEmpty ? nil : endpoint.query

    var request = URLRequest(url: components.url!)
    request.httpMethod = endpoint.method

    let (data, response) = try await session.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode ?? 500 < 300 else {
      throw URLError(.badServerResponse)
    }
    return try JSONDecoder().decode(Response.self, from: data)
  }
}

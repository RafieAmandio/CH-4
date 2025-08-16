// Endpoint.swift
import Foundation

public struct Endpoint<Response: Decodable> {
    public let path: String
    public let method: String
    public let query: [URLQueryItem]
    public let headers: [String: String]
    public let body: Data?

    public init(
        path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
    }
}

// Helpers for common JSON patterns
public extension Endpoint {
    static func get(_ path: String, query: [URLQueryItem] = [], headers: [String: String] = [:]) -> Self where Response == EmptyResponse {
        .init(path: path, method: "GET", query: query, headers: headers, body: nil)
    }

    static func postJSON<Body: Encodable, R: Decodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:]
    ) -> Endpoint<R> {
        var allHeaders = headers
        allHeaders["Content-Type"] = "application/json"
        let data = try? JSONEncoder().encode(body)
        return .init(path: path, method: "POST", headers: allHeaders, body: data)
    }
}

// Support "no payload" responses (e.g. 200 with {} or 204)
public struct EmptyResponse: Decodable {}

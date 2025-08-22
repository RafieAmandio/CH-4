//
//  Endpoint.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let queryParameters: [String: Any]
    let headers: [String: String]
    let body: [String: Any]?

    init(
        path: String,
        method: HTTPMethod = .GET,
        queryParameters: [String: Any] = [:],
        headers: [String: String] = [:],
        body: [String: Any]? = nil
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.headers = headers
        self.body = body
    }
}

extension APIEndpoint {
    static func login() -> APIEndpoint {
        APIEndpoint(path: "/auth/callback", method: .POST)
    }
    
    static func createEvent(_ event: EventCreationPayload) -> APIEndpoint {
        APIEndpoint(path: "/events", method: .POST, body: event.toDictionary())
    }
    
    static func completeProfile(_ profile: UpdateProfilePayload) -> APIEndpoint {
        APIEndpoint(path: "/users/me/complete", method: .POST, body: profile.toDictionary)
    }
    
    static func fetchProfessions() -> APIEndpoint {
        APIEndpoint(path: "/users/professions", method: .GET)
    }
    
    static func fetchGoals() -> APIEndpoint {
        APIEndpoint(path: "/attendee/goals-categories", method: .GET)
    }
    
    static func validateEvent(_ code: String)-> APIEndpoint {
        APIEndpoint(path: "/attendee/validate-event/\(code)", method: .GET)
    }
    
    static func joinEvent(_ eventId: String) -> APIEndpoint {
        APIEndpoint(path: "/attendee/register", method: .POST)
    }
}

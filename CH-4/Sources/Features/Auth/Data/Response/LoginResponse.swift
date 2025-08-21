//
//  LoginResponse.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public struct LoginResponse: Codable {
    let user: UserData
    let token: String
}

public struct UserData: Codable {
    let id: String
    let authProvider: String
    let email: String
    let username: String?
    let name: String
    let isFirst: Bool
    let isActive: Bool
    let deletedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case authProvider = "auth_provider"
        case email
        case username
        case name
        case isFirst
        case isActive = "is_active"
        case deletedAt = "deleted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

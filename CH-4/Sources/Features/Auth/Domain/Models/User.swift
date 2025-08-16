//
//  User.swift
//  CH-4
//
//  Created by Dwiki on 15/08/25.
//

import Foundation

public struct User: Codable, Equatable {
    public let userId: UUID
    public let email: String
    public let accessToken: String
    public let fullName: PersonNameComponents?
    public let signInTimestamp: Date
    
    public init(
        userId: UUID,
        email: String,
        accessToken: String,
        fullName: PersonNameComponents? = nil,
        signInTimestamp: Date = Date()
    ) {
        self.userId = userId
        self.email = email
        self.accessToken = accessToken
        self.fullName = fullName
        self.signInTimestamp = signInTimestamp
    }
}



//
//  PayloadDTO.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public struct UpdateProfilePayload: Codable {
    var name: String
    var username: String?
    var email: String?
    var professionId: UUID
    var photoLink: String?
    var linkedinUsername: String

    var toDictionary: [String: Any] {
        return [
            "name": self.name,
            "professionId": professionId.uuidString,
            "photoLink": photoLink ?? "",
            "linkedinUsername": linkedinUsername,
        ]
    }
}

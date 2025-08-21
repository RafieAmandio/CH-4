//
//  PayloadDTO.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public struct UpdateProfilePayload: Codable {
    var name: String
    var profession: String
    var linkedinUrl: String
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "profession": profession,
            "linkedin_url": linkedinUrl
        ]
    }
}

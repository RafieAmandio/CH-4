//
//  ValidateEventResponse.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import Foundation

public struct ValidateEventResponse: Codable {
    let success: Bool
    let message: String
    let data: EventDetailDTO
    let errors: [APIErrorItem]?
}


public struct EventDetailDTO: Codable {
    public let id: String
    public let name: String
    public let start: String
    public let end: String
    public let detail: String?
    public let photoLink: String?
    public let locationName: String?
    public let locationAddress: String?
    public let locationLink: String?
    public let latitude: Decimal?
    public let longitude: Decimal?
    public let link: String?
    public let status: String
    public let currentParticipants: Int
    public let code: String
    public let creator: CreatorDTO
    public let isAttendee: Bool?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case start
        case end
        case detail
        case photoLink = "photo_link"
        case locationName = "location_name"
        case locationAddress = "location_address"
        case locationLink = "location_link"
        case latitude
        case longitude
        case link
        case status
        case currentParticipants = "current_participants"
        case code
        case creator
        case isAttendee
    }
    
    public func toDomain() -> EventValidateModel {
        return EventValidateModel(name: self.name, photoLink: self.photoLink ?? "", currentParticipant: self.currentParticipants)
    }
}

public struct CreatorDTO: Codable {
    public let id: String
    public let name: String
    public let username: String?
}

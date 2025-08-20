// Data/Responses/CreateEventResponse.swift

import Foundation


public struct EventData: Codable {
    let event: EventResponseDTO
}

// Matches your API’s event JSON
struct EventResponseDTO: Codable {
    let id: String
    let createdBy: String
    let name: String
    let detail: String
    let photoLink: String?
    let locationName: String
    let locationAddress: String?
    let locationLink: String?
    let latitude: String
    let longitude: String
    let status: String
    let start: Date
    let end: Date
    let link: String?
    let code: String?
    let currentParticipants: Int
    let isActive: Bool
    let deletedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case createdBy = "created_by"
        case name
        case detail
        case photoLink = "photo_link"
        case locationName = "location_name"
        case locationAddress = "location_address"
        case locationLink = "location_link"
        case latitude
        case longitude
        case status
        case start
        case end
        case link
        case code
        case currentParticipants = "current_participants"
        case isActive = "is_active"
        case deletedAt = "deleted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}



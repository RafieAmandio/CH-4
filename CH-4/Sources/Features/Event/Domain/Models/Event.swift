//
//  Event.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public struct Event {
    public let id: String
    public let name: String
    public let start: Date
    public let end: Date
    public let detail: String
    public let locationName: String
    public let latitude: Double
    public let longitude: Double
    public let status: EventStatus
    public let maxParticipants: Int
    public let currentParticipants: Int
    public let createdBy: String
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
}

public enum EventStatus: String {
    case upcoming = "UPCOMING"
    case ongoing  = "ONGOING"
    case past     = "PAST"
}

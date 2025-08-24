//
//  PayloadDTO.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public struct EventCreationPayload: Codable {
    var name: String
    var start: String
    var end: String
    var description: String?
    var photoLink: String?
    var locationName: String?
    var locationAddress: String?
    var locationLink: String?
    var latitude: Double?
    var longitude: Double?
    var link: String?
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "start": start,
            "end": end,
            "description": description,
            "photoLink": photoLink,
            "locationName": locationName,
            "locationAddress": locationAddress,
            "locationLink": locationLink,
            "latitude": latitude,
            "longitude": longitude,
            "link": link
        ]
    }
}

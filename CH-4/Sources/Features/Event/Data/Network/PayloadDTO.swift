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
        var dict: [String: Any] = [
            "name": name,
            "start": start,
            "end": end
        ]
        
        // Only add optional fields if they have values
        if let description = description {
            dict["description"] = description
        }
        if let photoLink = photoLink {
            dict["photoLink"] = photoLink
        }
        if let locationName = locationName {
            dict["locationName"] = locationName
        }
        if let locationAddress = locationAddress {
            dict["locationAddress"] = locationAddress
        }
        if let locationLink = locationLink {
            dict["locationLink"] = locationLink
        }
        if let latitude = latitude {
            dict["latitude"] = latitude
        }
        if let longitude = longitude {
            dict["longitude"] = longitude
        }
        if let link = link {
            dict["link"] = link
        }
        
        return dict
    }
}

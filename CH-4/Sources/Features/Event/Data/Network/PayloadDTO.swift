//
//  PayloadDTO.swift
//  CH-4
//
//  Created by Dwiki on 20/08/25.
//

import Foundation

public struct EventCreationPayload: Codable {
    var name: String
    var description: String
    var datetime: String
    var location: String
    var latitude: Double
    var longitude: Double
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "description": description,
            "datetime": datetime,
            "location": location,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}

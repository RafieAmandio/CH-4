//
//  RegisterAttendee.swift
//  CH-4
//
//  Created by Dwiki on 23/08/25.
//

import Foundation

public struct RegisterAttendeePayload: Codable {
    public var eventCode: String
    public var name: String
    public var email: String
    public var professionId: String
    public var linkedinUsername: String?
    public var photoLink: String
    
    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "eventCode": eventCode,
            "nickname": name,
            "userEmail": email,
            "professionId": professionId,
            "photoLink": photoLink
        ]
        
        if let linkedinUsername = linkedinUsername {
            dict["linkedinUsername"] = linkedinUsername
        }
        
        return dict
    }
}

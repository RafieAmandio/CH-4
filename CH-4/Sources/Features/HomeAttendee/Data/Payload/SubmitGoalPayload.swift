//
//  SubmitGoalPayload.swift
//  CH-4
//
//  Created by Dwiki on 23/08/25.
//

import Foundation


public struct SubmitGoalPayload: Codable {
   public let goalsCategoryId: String
    
    public func toDictionary() -> [String: Any] {
        return [
            "goalsCategoryId" : goalsCategoryId
        ]
    }
}

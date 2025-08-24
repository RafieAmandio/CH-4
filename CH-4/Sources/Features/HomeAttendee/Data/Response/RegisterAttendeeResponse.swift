//
//  RegisterAttendeeResponse.swift
//  CH-4
//
//  Created by Dwiki on 23/08/25.
//


import Foundation

public struct RegisterAttendeeResponse: Codable {
    let message: String
    let data: RegisterAttendeeDTO?
    let errors: [APIErrorItem]?
}

public struct RegisterAttendeeDTO: Codable {
    let attendeeId: String?
    let accessToken: String?
}

//
//  FetchProfessionsResponse.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//
import Foundation


public struct FetchProfessionsResponse: Codable {
    let success: Bool
    let message: String
    let data: [ProfessionListDTO]
    let errors: [APIErrorItem]?
}


public struct ProfessionListDTO: Codable  {
    var categoryId: UUID
    var categoryName: String
    var professions: [Profession]
}


public struct Profession: Codable {
    var id: UUID
    var name: String
}

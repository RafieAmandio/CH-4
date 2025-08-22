// Data/Responses/CreateEventResponse.swift

import Foundation


// Matches your API’s event JSON
struct UpdateProfileResponseDTO: Codable {
    let id: String
    let name: String
    let email: String
    let username: String?  // Make optional since it can be null
    let linkedinUsername: String
    let photoLink: String
    let profession: ProfessionUpdateResponse
}

struct ProfessionUpdateResponse: Codable {
   var id: String
   var name: String
   var categoryName: String
}

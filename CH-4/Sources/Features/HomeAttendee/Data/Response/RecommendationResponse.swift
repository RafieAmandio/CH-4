//
//  RecommendationResponse.swift
//  CH-4
//
//  Created by Dwiki on 25/08/25.
//

import Foundation

public struct RecommendationResponse: Codable {
    let success: Bool?
    let message: String
    let data: RecommendationDataDTO
    let errors: [APIErrorItem]?
}

public struct RecommendationDataDTO: Codable {
    public let attendeeId: String
    public let eventId: String
    public let recommendations: [RecommendationItemDTO]
    
    private enum CodingKeys: String, CodingKey {
        case attendeeId = "attendeeId"
        case eventId = "eventId"
        case recommendations
    }
}

public struct RecommendationItemDTO: Codable {
    public let targetAttendeeId: String
    public let score: Decimal
    public let reasoning: String
    public let targetAttendee: TargetAttendeeDTO
    
    private enum CodingKeys: String, CodingKey {
        case targetAttendeeId = "targetAttendeeId"
        case score
        case reasoning
        case targetAttendee = "targetAttendee"
    }
    
    public func toDomain() -> RecommendationModel {
        return RecommendationModel(
            id: targetAttendeeId,
            score: score,
            reasoning: reasoning,
            targetAttendee: targetAttendee.toDomain()
        )
    }
}

public struct TargetAttendeeDTO: Codable {
    public let nickname: String
    public let profession: ProfessionDTO
    public let goalsCategory: GoalsCategoryDTO
    public let linkedinUsername: String?
    public let photoLink: String
    public let shareableAnswers: [ShareableAnswerDTO]
    
    private enum CodingKeys: String, CodingKey {
        case nickname
        case profession
        case goalsCategory = "goalsCategory"
        case linkedinUsername = "linkedinUsername"
        case photoLink = "photoLink"
        case shareableAnswers = "shareableAnswers"
    }
    
    public func toDomain() -> TargetAttendeeModel {
        return TargetAttendeeModel(
            nickname: nickname,
            profession: profession.toDomain(),
            goalsCategory: goalsCategory.toDomain(),
            linkedinUsername: linkedinUsername,
            photoLink: photoLink,
            shareableAnswers: shareableAnswers.map { $0.toDomain() }
        )
    }
}

public struct ProfessionDTO: Codable {
    public let name: String
    public let categoryName: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case categoryName = "categoryName"
    }
    
    public func toDomain() -> ProfessionModelRecommendation {
        return ProfessionModelRecommendation(
            name: name,
            categoryName: categoryName
        )
    }
}

public struct GoalsCategoryDTO: Codable {
    public let name: String
    
    public func toDomain() -> GoalsCategoryModel {
        return GoalsCategoryModel(name: name)
    }
}

public struct ShareableAnswerDTO: Codable {
    public let question: String
    public let questionType: String
    public let answerLabel: String?
    public let textValue: String?
    public let numberValue: Decimal?
    public let dateValue: String? // Keep as String, convert to Date in domain if needed
    public let rank: Int?
    
    private enum CodingKeys: String, CodingKey {
        case question
        case questionType = "questionType"
        case answerLabel = "answerLabel"
        case textValue = "textValue"
        case numberValue = "numberValue"
        case dateValue = "dateValue"
        case rank
    }
    
    public func toDomain() -> ShareableAnswerModel {
        return ShareableAnswerModel(
            question: question,
            questionType: QuestionTypeResponse(rawValue: questionType) ?? .text,
            answerLabel: answerLabel,
            textValue: textValue,
            numberValue: numberValue,
            dateValue: dateValue,
            rank: rank
        )
    }
}

public enum QuestionTypeResponse: String, CaseIterable, Codable {
    case text = "text"
    case number = "number"
    case date = "date"
    case multipleChoice = "multiple_choice"
    case ranking = "ranking"
    case boolean = "boolean"
}

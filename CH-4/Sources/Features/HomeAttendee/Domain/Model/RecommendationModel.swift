//
//  RecommendationModels.swift
//  CH-4
//
//  Created by Dwiki on 25/08/25.
//

import Foundation

// MARK: - Domain Models

public struct RecommendationModel: Identifiable, Equatable {
    public let id: String
    public let score: Decimal
    public let reasoning: String
    public let targetAttendee: TargetAttendeeModel
    
    public init(id: String, score: Decimal, reasoning: String, targetAttendee: TargetAttendeeModel) {
        self.id = id
        self.score = score
        self.reasoning = reasoning
        self.targetAttendee = targetAttendee
    }
    
    // Computed property for score as percentage
    public var scorePercentage: Double {
        return Double(truncating: score as NSNumber) * 100
    }
}

public struct TargetAttendeeModel: Equatable {
    public let nickname: String
    public let profession: ProfessionModelRecommendation
    public let goalsCategory: GoalsCategoryModel
    public let linkedinUsername: String?
    public let photoLink: String
    public let shareableAnswers: [ShareableAnswerModel]
    
    public init(
        nickname: String,
        profession: ProfessionModelRecommendation,
        goalsCategory: GoalsCategoryModel,
        linkedinUsername: String?,
        photoLink: String,
        shareableAnswers: [ShareableAnswerModel]
    ) {
        self.nickname = nickname
        self.profession = profession
        self.goalsCategory = goalsCategory
        self.linkedinUsername = linkedinUsername
        self.photoLink = photoLink
        self.shareableAnswers = shareableAnswers
    }
    
    // Helper computed properties
    public var hasLinkedIn: Bool {
        return linkedinUsername != nil && !linkedinUsername!.isEmpty
    }
    
    public var linkedinUrl: String? {
        guard let username = linkedinUsername else { return nil }
        return "https://www.linkedin.com/in/\(username)"
    }
}

public struct ProfessionModelRecommendation: Equatable {
    public let name: String
    public let categoryName: String
    
    public init(name: String, categoryName: String) {
        self.name = name
        self.categoryName = categoryName
    }
}

public struct GoalsCategoryModel: Equatable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct ShareableAnswerModel: Equatable {
    public let question: String
    public let questionType: QuestionTypeResponse
    public let answerLabel: String?
    public let textValue: String?
    public let numberValue: Decimal?
    public let dateValue: String?
    public let rank: Int?
    
    public init(
        question: String,
        questionType: QuestionTypeResponse,
        answerLabel: String?,
        textValue: String?,
        numberValue: Decimal?,
        dateValue: String?,
        rank: Int?
    ) {
        self.question = question
        self.questionType = questionType
        self.answerLabel = answerLabel
        self.textValue = textValue
        self.numberValue = numberValue
        self.dateValue = dateValue
        self.rank = rank
    }
    
    // Helper computed properties
    public var displayValue: String {
        switch questionType {
        case .text:
            return textValue ?? answerLabel ?? ""
        case .number:
            if let numberValue = numberValue {
                return String(describing: numberValue)
            }
            return answerLabel ?? ""
        case .date:
            return dateValue ?? answerLabel ?? ""
        case .multipleChoice, .boolean:
            return answerLabel ?? ""
        case .ranking:
            if let rank = rank {
                return "Rank \(rank)"
            }
            return answerLabel ?? ""
        }
    }
    
    public var parsedDate: Date? {
        guard let dateValue = dateValue else { return nil }
        
        let formatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateValue) {
                return date
            }
        }
        
        return nil
    }
}

import Foundation

public struct SubmitGoalResponse: Codable {
    public let data: SubmitGoalResponseDTO
    public let message: String?
    public let error:[APIErrorItem]
}

public struct SubmitAnswerResponse: Codable {
    public let data: SubmitAnswerResponseDTO
    public let message: String?
    public let error:[APIErrorItem]
}

public struct SubmitAnswerResponseDTO: Codable {
    public let answersProcessed: Int
}

public struct SubmitGoalResponseDTO: Codable {
    public let questions: [QuestionDTO]
}
// MARK: - Main Response DTO
public struct GoalQuestionResponse: Codable {
    public let message: String
    public let data: GoalQuestionData
}

public struct GoalQuestionData: Codable {
    public let attendeeId: String
    public let goalsCategory: GoalCategory
    public let questions: [QuestionDTO]
}

public struct GoalCategory: Codable {
    public let id: String
    public let name: String
}

// MARK: - Question DTOs
public struct QuestionDTO: Codable, Identifiable {
    public let id: String
    public let question: String
    public let type: QuestionType
    public let placeholder: String?
    public let displayOrder: Int
    public let isRequired: Bool
    public let isShareable: Bool
    public let constraints: QuestionConstraints
    public let answerOptions: [AnswerOptionDTO]
    
    public init(
        id: String,
        question: String,
        type: QuestionType,
        placeholder: String?,
        displayOrder: Int,
        isRequired: Bool,
        isShareable: Bool,
        constraints: QuestionConstraints,
        answerOptions: [AnswerOptionDTO]
    ) {
        self.id = id
        self.question = question
        self.type = type
        self.placeholder = placeholder
        self.displayOrder = displayOrder
        self.isRequired = isRequired
        self.isShareable = isShareable
        self.constraints = constraints
        self.answerOptions = answerOptions
    }
}

public enum QuestionType: String, Codable, CaseIterable {
    case singleChoice = "SINGLE_CHOICE"
    case multiSelect = "MULTI_SELECT"
    case rankedChoice = "RANKED_CHOICE"
    case freeText = "FREE_TEXT"
    case number = "NUMBER"
    case scale = "SCALE"
    case date = "DATE"
    
    public var displayName: String {
        switch self {
        case .singleChoice: return "Single Choice"
        case .multiSelect: return "Multiple Select"
        case .rankedChoice: return "Ranked Choice"
        case .freeText: return "Free Text"
        case .number: return "Number"
        case .scale: return "Scale"
        case .date: return "Date"
        }
    }
}

public struct QuestionConstraints: Codable {
    public let minSelect: Int?
    public let maxSelect: Int?
    public let requireRanking: Bool?
    public let isUsingOther: Bool
    public let textMaxLen: Int?
    public let numberMin: Double?
    public let numberMax: Double?
    public let numberStep: Double?
    
    public init(
        minSelect: Int? = nil,
        maxSelect: Int? = nil,
        requireRanking: Bool? = nil,
        isUsingOther: Bool = false,
        textMaxLen: Int? = nil,
        numberMin: Double? = nil,
        numberMax: Double? = nil,
        numberStep: Double? = nil
    ) {
        self.minSelect = minSelect
        self.maxSelect = maxSelect
        self.requireRanking = requireRanking
        self.isUsingOther = isUsingOther
        self.textMaxLen = textMaxLen
        self.numberMin = numberMin
        self.numberMax = numberMax
        self.numberStep = numberStep
    }
}

public struct AnswerOptionDTO: Codable, Identifiable {
    public let id: String
    public let label: String
    public let value: String?
    public let displayOrder: Int
    
    public init(
        id: String,
        label: String,
        value: String? = nil,
        displayOrder: Int
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.displayOrder = displayOrder
    }
}

// MARK: - Answer DTOs (for submission)
public struct AnswerSubmissionRequest: Codable {
    public let answers: [AnswerDTO]
    
    public init(answers: [AnswerDTO]) {
        self.answers = answers
    }
    
    // MARK: - Dictionary Conversion
    public func toDictionary() -> [String: Any] {
        let answersArray = answers.map { answer in
            var answerDict: [String: Any] = [
                "questionId": answer.questionId
            ]
            
            // Add optional fields only if they have values
            if let answerOptionId = answer.answerOptionId {
                answerDict["answerOptionId"] = answerOptionId
            }
            
            if let textValue = answer.textValue {
                answerDict["textValue"] = textValue
            }
            
            if let numberValue = answer.numberValue {
                answerDict["numberValue"] = numberValue
            }
            
            if let dateValue = answer.dateValue {
                answerDict["dateValue"] = dateValue
            }
            
            if let rank = answer.rank {
                answerDict["rank"] = rank
            }
            
            if let weight = answer.weight {
                answerDict["weight"] = weight
            }
            
            return answerDict
        }
        
        return [
            "answers": answersArray
        ]
    }
    
    // MARK: - Debug Description
    public var debugDescription: String {
        let answersDescription = answers.map { answer in
            var desc = "QuestionID: \(answer.questionId)"
            
            if let answerOptionId = answer.answerOptionId {
                desc += ", OptionID: \(answerOptionId)"
            }
            
            if let textValue = answer.textValue {
                desc += ", Text: \(textValue)"
            }
            
            if let numberValue = answer.numberValue {
                desc += ", Number: \(numberValue)"
            }
            
            if let dateValue = answer.dateValue {
                desc += ", Date: \(dateValue)"
            }
            
            if let rank = answer.rank {
                desc += ", Rank: \(rank)"
            }
            
            if let weight = answer.weight {
                desc += ", Weight: \(weight)"
            }
            
            return desc
        }.joined(separator: "\n")
        
        return "AnswerSubmissionRequest:\n\(answersDescription)"
    }
}

public struct AnswerDTO: Codable {
    public let questionId: String
    public let answerOptionId: String?
    public let textValue: String?
    public let numberValue: Double?
    public let dateValue: Date?
    public let rank: Int?
    public let weight: Double?
    
    public init(
        questionId: String,
        answerOptionId: String? = nil,
        textValue: String? = nil,
        numberValue: Double? = nil,
        dateValue: Date? = nil,
        rank: Int? = nil,
        weight: Double? = nil
    ) {
        self.questionId = questionId
        self.answerOptionId = answerOptionId
        self.textValue = textValue
        self.numberValue = numberValue
        self.dateValue = dateValue
        self.rank = rank
        self.weight = weight
    }
}

// MARK: - Extensions for easier usage
extension QuestionDTO {
    public var sortedAnswerOptions: [AnswerOptionDTO] {
        return answerOptions.sorted { $0.displayOrder < $1.displayOrder }
    }
    
    public var hasOtherOption: Bool {
        return constraints.isUsingOther
    }
    
    public var isMultipleChoice: Bool {
        return type == .singleChoice || type == .multiSelect || type == .rankedChoice
    }
}

extension Array where Element == QuestionDTO {
    public var sortedByDisplayOrder: [QuestionDTO] {
        return sorted { $0.displayOrder < $1.displayOrder }
    }
    
    public var requiredQuestions: [QuestionDTO] {
        return filter { $0.isRequired }
    }
}

// MARK: - JSON Decoding Helper
extension GoalQuestionResponse {
    public static func decode(from data: Data) throws -> GoalQuestionResponse {
        let decoder = JSONDecoder()
        
        // Handle different date formats if needed
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return try decoder.decode(GoalQuestionResponse.self, from: data)
    }
}

// MARK: - JSON Encoding Helper
extension AnswerSubmissionRequest {
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        
        // Handle date encoding
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        return try encoder.encode(self)
    }
}

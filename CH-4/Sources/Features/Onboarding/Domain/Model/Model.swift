struct GoalSelectionResponse: Codable {
    let message: String
    let data: GoalData
}

struct GoalData: Codable {
    let attendeeId: String
    let goalsCategory: GoalsCategory
    let questions: [Question]
}

public struct GoalsCategory: Codable {
    let id: String
    let name: String
}

struct Question: Codable {
    let id: String
    let question: String
    let type: QuestionType
    let placeholder: String?
    let displayOrder: Int
    let isRequired: Bool
    let isShareable: Bool
    let constraints: QuestionConstraints
    let answerOptions: [AnswerOption]
}

enum QuestionType: String, Codable {
    case multipleChoice = "MULTIPLE_CHOICE"
    case singleChoice = "SINGLE_CHOICE"
    case text = "TEXT"
    case number = "NUMBER"
    case ranking = "RANKING"
    // Add other types as needed
}

struct QuestionConstraints: Codable {
    let minSelect: Int
    let maxSelect: Int?
    let requireRanking: Bool
    let isUsingOther: Bool
    let textMaxLen: Int?
    let numberMin: Double?
    let numberMax: Double?
    let numberStep: Double?
}

struct AnswerOption: Codable {
    let id: String
    let label: String
    let value: String?
    let displayOrder: Int
}

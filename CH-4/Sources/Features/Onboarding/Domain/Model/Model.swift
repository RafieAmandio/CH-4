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

public struct Question: Codable {
    public let id: String
    public let question: String
    public let type: QuestionType
    public let placeholder: String?
    public let displayOrder: Int
    public let isRequired: Bool
    public let isShareable: Bool
    public let constraints: QuestionConstraints
    public let answerOptions: [AnswerOption]
}

public struct AnswerOption: Codable {
  public  let id: String
    public let label: String
    public let value: String?
    public let displayOrder: Int
}

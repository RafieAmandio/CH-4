import Foundation

// MARK: - Mock Data Provider
struct MockQuestionProvider {
    
    static let mockQuestions: [QuestionDTO] = [
        // Single Choice Question
        QuestionDTO(
            id: "q1",
            question: "What is your primary career goal?",
            type: .singleChoice,
            placeholder: nil,
            displayOrder: 1,
            isRequired: true,
            isShareable: true,
            constraints: QuestionConstraints(
                minSelect: nil,
                maxSelect: nil,
                requireRanking: nil,
                isUsingOther: true,
                textMaxLen: nil,
                numberMin: nil,
                numberMax: nil,
                numberStep: nil
            ),
            answerOptions: [
                AnswerOptionDTO(id: "opt1", label: "Get promoted", value: "promotion", displayOrder: 1),
                AnswerOptionDTO(id: "opt2", label: "Learn new skills", value: "skills", displayOrder: 2),
                AnswerOptionDTO(id: "opt3", label: "Change career", value: "change", displayOrder: 3),
                AnswerOptionDTO(id: "opt4", label: "Start own business", value: "business", displayOrder: 4)
            ]
        ),
        
        // Multi Select Question
        QuestionDTO(
            id: "q2",
            question: "Which skills would you like to improve? (Select 2-3)",
            type: .multiSelect,
            placeholder: nil,
            displayOrder: 2,
            isRequired: true,
            isShareable: true,
            constraints: QuestionConstraints(
                minSelect: 2,
                maxSelect: 3,
                requireRanking: nil,
                isUsingOther: true,
                textMaxLen: nil,
                numberMin: nil,
                numberMax: nil,
                numberStep: nil
            ),
            answerOptions: [
                AnswerOptionDTO(id: "skill1", label: "Leadership", value: "leadership", displayOrder: 1),
                AnswerOptionDTO(id: "skill2", label: "Communication", value: "communication", displayOrder: 2),
                AnswerOptionDTO(id: "skill3", label: "Technical Skills", value: "technical", displayOrder: 3),
                AnswerOptionDTO(id: "skill4", label: "Project Management", value: "pm", displayOrder: 4),
                AnswerOptionDTO(id: "skill5", label: "Marketing", value: "marketing", displayOrder: 5)
            ]
        ),
        
        // Free Text Question
        QuestionDTO(
            id: "q3",
            question: "Describe your ideal work environment",
            type: .freeText,
            placeholder: "Tell us about your preferred work setting...",
            displayOrder: 3,
            isRequired: true,
            isShareable: false,
            constraints: QuestionConstraints(
                minSelect: nil,
                maxSelect: nil,
                requireRanking: nil,
                isUsingOther: false,
                textMaxLen: 500,
                numberMin: nil,
                numberMax: nil,
                numberStep: nil
            ),
            answerOptions: []
        ),
        
        // Number Question
        QuestionDTO(
            id: "q4",
            question: "How many years of experience do you have in your field?",
            type: .number,
            placeholder: "Enter number of years",
            displayOrder: 4,
            isRequired: true,
            isShareable: true,
            constraints: QuestionConstraints(
                minSelect: nil,
                maxSelect: nil,
                requireRanking: nil,
                isUsingOther: false,
                textMaxLen: nil,
                numberMin: 0,
                numberMax: 50,
                numberStep: 0.5
            ),
            answerOptions: []
        ),
        
        // Scale Question
        QuestionDTO(
            id: "q5",
            question: "Rate your satisfaction with your current role (1-10)",
            type: .scale,
            placeholder: nil,
            displayOrder: 5,
            isRequired: false,
            isShareable: true,
            constraints: QuestionConstraints(
                minSelect: nil,
                maxSelect: nil,
                requireRanking: nil,
                isUsingOther: false,
                textMaxLen: nil,
                numberMin: 1,
                numberMax: 10,
                numberStep: 1
            ),
            answerOptions: []
        ),
        
        // Date Question
        QuestionDTO(
            id: "q6",
            question: "When do you plan to achieve your primary goal?",
            type: .date,
            placeholder: nil,
            displayOrder: 6,
            isRequired: true,
            isShareable: false,
            constraints: QuestionConstraints(
                minSelect: nil,
                maxSelect: nil,
                requireRanking: nil,
                isUsingOther: false,
                textMaxLen: nil,
                numberMin: nil,
                numberMax: nil,
                numberStep: nil
            ),
            answerOptions: []
        ),
        
        // Ranked Choice Question
        QuestionDTO(
            id: "q7",
            question: "Rank these work priorities in order of importance to you",
            type: .rankedChoice,
            placeholder: nil,
            displayOrder: 7,
            isRequired: true,
            isShareable: true,
            constraints: QuestionConstraints(
                minSelect: nil,
                maxSelect: nil,
                requireRanking: true,
                isUsingOther: false,
                textMaxLen: nil,
                numberMin: nil,
                numberMax: nil,
                numberStep: nil
            ),
            answerOptions: [
                AnswerOptionDTO(id: "priority1", label: "Work-life balance", value: "balance", displayOrder: 1),
                AnswerOptionDTO(id: "priority2", label: "High salary", value: "salary", displayOrder: 2),
                AnswerOptionDTO(id: "priority3", label: "Career growth", value: "growth", displayOrder: 3),
                AnswerOptionDTO(id: "priority4", label: "Job security", value: "security", displayOrder: 4),
                AnswerOptionDTO(id: "priority5", label: "Flexible schedule", value: "flexibility", displayOrder: 5)
            ]
        )
    ]
    
    // Get questions by type for testing specific components
    static func getQuestions(ofType type: QuestionType) -> [QuestionDTO] {
        return mockQuestions.filter { $0.type == type }
    }
    
    // Get single question by type
    static func getQuestion(ofType type: QuestionType) -> QuestionDTO? {
        return mockQuestions.first { $0.type == type }
    }
    
    // Create mock response
    static func createMockResponse() -> GoalQuestionResponse {
        return GoalQuestionResponse(
            message: "Goals category updated successfully",
            data: GoalQuestionData(
                attendeeId: "mock-attendee-id",
                goalsCategory: GoalCategory(
                    id: "mock-goal-id",
                    name: "Career Development"
                ),
                questions: mockQuestions
            )
        )
    }
}

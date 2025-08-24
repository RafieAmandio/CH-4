import Foundation

// MARK: - Answer State Management (Updated for QuestionDTO)
class QuestionAnswerManager: ObservableObject {
    @Published var answers: [String: [AnswerDTO]] = [:] // questionId -> [AnswerDTO]
    
    // MARK: - Single Choice
    func setSingleChoice(questionId: String, optionId: String) {
        answers[questionId] = [AnswerDTO(
            questionId: questionId,
            answerOptionId: optionId,
            textValue: nil,
            numberValue: nil,
            dateValue: nil,
            rank: nil,
            weight: nil
        )]
    }
    
    // MARK: - Multi Select
    func toggleMultiSelect(questionId: String, optionId: String) {
        var currentAnswers = answers[questionId] ?? []
        
        print("🔄 Toggle multi-select: \(questionId) - \(optionId)")
        print("📋 Current answers before toggle: \(currentAnswers.count)")
        
        // Check if option is already selected
        if let index = currentAnswers.firstIndex(where: { $0.answerOptionId == optionId }) {
            // Remove if already selected
            currentAnswers.remove(at: index)
            print("❌ Removed option: \(optionId)")
        } else {
            // Add new selection
            let newAnswer = AnswerDTO(
                questionId: questionId,
                answerOptionId: optionId,
                textValue: nil,
                numberValue: nil,
                dateValue: nil,
                rank: nil,
                weight: nil
            )
            currentAnswers.append(newAnswer)
            print("✅ Added option: \(optionId)")
        }
        
        answers[questionId] = currentAnswers.isEmpty ? nil : currentAnswers
        print("📊 Final answers count: \(currentAnswers.count)")
        
        // Force UI update
        objectWillChange.send()
    }
    
    // Check if option is selected in multi-select
    func isMultiSelectOptionSelected(questionId: String, optionId: String) -> Bool {
        guard let currentAnswers = answers[questionId] else {
            print("❓ No answers found for question: \(questionId)")
            return false
        }
        let isSelected = currentAnswers.contains { $0.answerOptionId == optionId }
        print("🔍 Checking if \(optionId) is selected: \(isSelected)")
        return isSelected
    }
    
    // MARK: - Ranked Choice
    func setRankedChoice(questionId: String, optionId: String, rank: Int) {
        var currentAnswers = answers[questionId] ?? []
        
        // Remove existing answer for this option
        currentAnswers.removeAll { $0.answerOptionId == optionId }
        
        // Add new ranked answer
        let rankedAnswer = AnswerDTO(
            questionId: questionId,
            answerOptionId: optionId,
            textValue: nil,
            numberValue: nil,
            dateValue: nil,
            rank: rank,
            weight: nil
        )
        currentAnswers.append(rankedAnswer)
        
        answers[questionId] = currentAnswers
    }
    
    // MARK: - Free Text (including "Other" option)
    func setFreeText(questionId: String, text: String, optionId: String? = nil) {
        answers[questionId] = [AnswerDTO(
            questionId: questionId,
            answerOptionId: optionId, // nil for pure text, optionId for "Other" selection
            textValue: text,
            numberValue: nil,
            dateValue: nil,
            rank: nil,
            weight: nil
        )]
    }
    
    // MARK: - Number/Scale
    func setNumber(questionId: String, number: Double) {
        answers[questionId] = [AnswerDTO(
            questionId: questionId,
            answerOptionId: nil,
            textValue: nil,
            numberValue: number,
            dateValue: nil,
            rank: nil,
            weight: nil
        )]
    }
    
    // MARK: - Date
    func setDate(questionId: String, date: Date) {
        answers[questionId] = [AnswerDTO(
            questionId: questionId,
            answerOptionId: nil,
            textValue: nil,
            numberValue: nil,
            dateValue: date,
            rank: nil,
            weight: nil
        )]
    }
    
    // MARK: - Utility Methods
    func getAllAnswers() -> [AnswerDTO] {
        return answers.values.flatMap { $0 }
    }
    
    func getAnswers(for questionId: String) -> [AnswerDTO] {
        return answers[questionId] ?? []
    }
    
    func clearAnswers(for questionId: String) {
        answers[questionId] = nil
    }
    
    func isQuestionAnswered(_ question: QuestionDTO) -> Bool {
        guard let questionAnswers = answers[question.id], !questionAnswers.isEmpty else {
            return false
        }
        
        // Check constraints
        switch question.type {
        case .multiSelect:
            let selectedCount = questionAnswers.count
            let minSelect = question.constraints.minSelect ?? 0
            let maxSelect = question.constraints.maxSelect
            
            if selectedCount < minSelect {
                return false
            }
            if let maxSelect = maxSelect, selectedCount > maxSelect {
                return false
            }
        case .freeText:
            // Check text length constraints
            if let textAnswer = questionAnswers.first?.textValue {
                if let maxLen = question.constraints.textMaxLen, textAnswer.count > maxLen {
                    return false
                }
                return !textAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return false
        case .number, .scale:
            // Check number constraints
            if let numberAnswer = questionAnswers.first?.numberValue {
                if let min = question.constraints.numberMin, numberAnswer < min {
                    return false
                }
                if let max = question.constraints.numberMax, numberAnswer > max {
                    return false
                }
                return true
            }
            return false
        case .rankedChoice:
            // Check if all required options are ranked
            if let requireRanking = question.constraints.requireRanking, requireRanking {
                let rankedCount = questionAnswers.filter { $0.rank != nil }.count
                return rankedCount == question.answerOptions.count
            }
            return !questionAnswers.isEmpty
        default:
            break
        }
        
        return true
    }
    
    // Get selected option IDs for a question (useful for UI)
    func getSelectedOptionIds(for questionId: String) -> Set<String> {
        guard let questionAnswers = answers[questionId] else { return Set() }
        let optionIds = questionAnswers.compactMap { $0.answerOptionId }
        return Set(optionIds)
    }
    
    // Get text answer for a question
    func getTextAnswer(for questionId: String) -> String? {
        return answers[questionId]?.first?.textValue
    }
    
    // Get number answer for a question
    func getNumberAnswer(for questionId: String) -> Double? {
        return answers[questionId]?.first?.numberValue
    }
    
    // Get date answer for a question
    func getDateAnswer(for questionId: String) -> Date? {
        return answers[questionId]?.first?.dateValue
    }
}

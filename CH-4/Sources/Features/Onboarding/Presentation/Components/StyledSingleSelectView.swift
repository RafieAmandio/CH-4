import SwiftUI
import UIComponentsKit

// MARK: - Styled Single Select View
struct StyledSingleSelectView: View {
    let question: QuestionDTO
    @ObservedObject var answerManager: QuestionAnswerManager
    @State private var selectedOptionId: String?
    @State private var otherText: String = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        ApplyBackground {
            VStack(alignment: .leading, spacing: 32) {
                // Question Title
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.question)
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                
                    // Subtitle
                    Text("Pick one!")
                        .font(AppFont.bodySmallMedium)
                        .multilineTextAlignment(.leading)
                }
                
                // Options Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(question.answerOptions) { option in
                        SingleSelectOptionButton(
                            option: option,
                            isSelected: selectedOptionId == option.id
                        ) {
                            selectedOptionId = option.id
                            answerManager.setSingleChoice(questionId: question.id, optionId: option.id)
                        }
                    }
                }
                
                // "Other" option if enabled
                if question.constraints.isUsingOther {
                    VStack(alignment: .leading, spacing: 12) {
                        SingleSelectOptionButton(
                            text: "Other",
                            isSelected: selectedOptionId == "other"
                        ) {
                            selectedOptionId = "other"
                        }
                        
                        if selectedOptionId == "other" {
                            TextField("Please specify...", text: $otherText)
                                .textFieldStyle(CustomSingleSelectTextFieldStyle())
                                .onChange(of: otherText) { newValue in
                                    if !newValue.isEmpty {
                                        answerManager.setFreeText(questionId: question.id, text: newValue, optionId: "other")
                                    }
                                }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Initialize selected option from existing answers
            let existingAnswers = answerManager.getAnswers(for: question.id)
            if let firstAnswer = existingAnswers.first {
                selectedOptionId = firstAnswer.answerOptionId
                if firstAnswer.answerOptionId == "other", let text = firstAnswer.textValue {
                    otherText = text
                }
            }
        }
    }
}

// MARK: - Single Select Option Button
struct SingleSelectOptionButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    init(option: AnswerOptionDTO, isSelected: Bool, action: @escaping () -> Void) {
        self.text = option.label
        self.isSelected = isSelected
        self.action = action
    }
    
    init(text: String, isSelected: Bool, action: @escaping () -> Void) {
        self.text = text
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Radio button indicator
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? AppColors.primary : Color.gray.opacity(0.4),
                            lineWidth: isSelected ? 2 : 1
                        )
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(text)
                    .font(AppFont.bodySmallMedium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Background fill
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.TextFieldBackground)
                    
                    // Border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? AppColors.primary : Color.gray.opacity(0.4),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

// MARK: - Custom Text Field Style for Single Select
struct CustomSingleSelectTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                }
            )
            .foregroundColor(.white)
    }
}

// MARK: - Preview
struct StyledSingleSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let mockQuestion = QuestionDTO(
            id: "single_question",
            question: "What is your primary career goal right now?",
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
                AnswerOptionDTO(id: "promotion", label: "Get promoted at my current job", value: "promotion", displayOrder: 1),
                AnswerOptionDTO(id: "newjob", label: "Find a new job", value: "newjob", displayOrder: 2),
                AnswerOptionDTO(id: "skills", label: "Learn new skills", value: "skills", displayOrder: 3),
                AnswerOptionDTO(id: "freelance", label: "Start freelancing", value: "freelance", displayOrder: 4),
                AnswerOptionDTO(id: "business", label: "Start my own business", value: "business", displayOrder: 5),
                AnswerOptionDTO(id: "network", label: "Expand my network", value: "network", displayOrder: 6)
            ]
        )
        
        StyledSingleSelectView(
            question: mockQuestion,
            answerManager: QuestionAnswerManager()
        )
        .preferredColorScheme(.dark)
    }
}

// MARK: - Complete Styled Single Select Onboarding View
struct CompleteSingleSelectOnboardingView: View {
    let question: QuestionDTO
    @ObservedObject var answerManager: QuestionAnswerManager
    let onContinue: () -> Void
    
    var canContinue: Bool {
        return !question.isRequired || answerManager.isQuestionAnswered(question)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("OnBoarding")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Step 1")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)
            
            // Main Content
            StyledSingleSelectView(question: question, answerManager: answerManager)
            
            // Continue Button
            VStack(spacing: 16) {
                CustomButton(
                    title: "Continue",
                    style: .primary
                ) {
                    onContinue()
                }
                .disabled(!canContinue)
                .opacity(canContinue ? 1.0 : 0.6)
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .background(AppColors.offBlack)
        }
        .background(AppColors.offBlack)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Test View for Single Select Development
struct StyledSingleSelectTestView: View {
    @StateObject private var answerManager = QuestionAnswerManager()
    
    var body: some View {
        let mockQuestion = QuestionDTO(
            id: "test_single_question",
            question: "What is your primary career goal right now?",
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
                AnswerOptionDTO(id: "promotion", label: "Get promoted at my current job", value: "promotion", displayOrder: 1),
                AnswerOptionDTO(id: "newjob", label: "Find a new job", value: "newjob", displayOrder: 2),
                AnswerOptionDTO(id: "skills", label: "Learn new skills", value: "skills", displayOrder: 3),
                AnswerOptionDTO(id: "freelance", label: "Start freelancing", value: "freelance", displayOrder: 4),
                AnswerOptionDTO(id: "business", label: "Start my own business", value: "business", displayOrder: 5),
                AnswerOptionDTO(id: "network", label: "Expand my network", value: "network", displayOrder: 6)
            ]
        )
        
        CompleteSingleSelectOnboardingView(
            question: mockQuestion,
            answerManager: answerManager,
            onContinue: {
                print("Continue tapped!")
                let answers = answerManager.getAllAnswers()
                print("Selected answer: \(answers)")
                if let answer = answers.first {
                    print("Selected option: \(answer.answerOptionId ?? "none")")
                    print("Text value: \(answer.textValue ?? "none")")
                }
            }
        )
    }
}

// MARK: - Updated Dynamic Question View to include styled single select

// MARK: - Mock Data Extension for Single Select
extension MockQuestionProvider {
    static let singleChoiceQuestion = QuestionDTO(
        id: "career_goal_question",
        question: "What is your primary career goal right now?",
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
            textMaxLen: 200,
            numberMin: nil,
            numberMax: nil,
            numberStep: nil
        ),
        answerOptions: [
            AnswerOptionDTO(id: "promotion", label: "Get promoted at my current job", value: "promotion", displayOrder: 1),
            AnswerOptionDTO(id: "newjob", label: "Find a new job", value: "newjob", displayOrder: 2),
            AnswerOptionDTO(id: "skills", label: "Learn new skills", value: "skills", displayOrder: 3),
            AnswerOptionDTO(id: "freelance", label: "Start freelancing", value: "freelance", displayOrder: 4),
            AnswerOptionDTO(id: "business", label: "Start my own business", value: "business", displayOrder: 5),
            AnswerOptionDTO(id: "network", label: "Expand my network", value: "network", displayOrder: 6)
        ]
    )
}

// MARK: - Preview for Test View
struct StyledSingleSelectTestView_Previews: PreviewProvider {
    static var previews: some View {
        StyledSingleSelectTestView()
    }
}

import SwiftUI
import UIComponentsKit

// MARK: - Styled Multi Select View
struct StyledMultiSelectView: View {
    let question: QuestionDTO
    @ObservedObject var answerManager: QuestionAnswerManager
    @State private var otherText: String = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),

    ]
    
    var body: some View {
        ApplyBackground {
            VStack(alignment: .leading, spacing: 32) {
                // Question Title
                VStack(alignment:.leading, spacing:10) {
                    Text(question.question)
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                
                    // Subtitle
                    Text("Pick one or more!")
                        .font(AppFont.bodySmallMedium)
                        .multilineTextAlignment(.leading)
                       
                }
                // Options Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(question.answerOptions) { option in
                        MultiSelectOptionButton(
                            option: option,
                            isSelected: answerManager.isMultiSelectOptionSelected(
                                questionId: question.id,
                                optionId: option.id
                            )
                        ) {
                            answerManager.toggleMultiSelect(questionId: question.id, optionId: option.id)
                        }
                    }
                }
                
                // "Other" option if enabled
                if question.constraints.isUsingOther {
                    VStack(alignment: .leading, spacing: 12) {
                        MultiSelectOptionButton(
                            text: "Other",
                            isSelected: answerManager.isMultiSelectOptionSelected(
                                questionId: question.id,
                                optionId: "other"
                            )
                        ) {
                            if !otherText.isEmpty {
                                answerManager.toggleMultiSelect(questionId: question.id, optionId: "other")
                            }
                        }
                        
                        if answerManager.isMultiSelectOptionSelected(questionId: question.id, optionId: "other") {
                            TextField("Please specify...", text: $otherText)
                                .textFieldStyle(CustomTextFieldStyle())
                                .onChange(of: otherText) { newValue in
                                    if !newValue.isEmpty {
                                        answerManager.setFreeText(questionId: question.id, text: newValue, optionId: "other")
                                    } else {
                                        answerManager.toggleMultiSelect(questionId: question.id, optionId: "other")
                                    }
                                }
                        }
                    }
                }
                
                Spacer()
          
            }

         
        }
    }
}

// MARK: - Multi Select Option Button
struct MultiSelectOptionButton: View {
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
            Text(text)
                .font(AppFont.bodySmallMedium)
                .foregroundColor(.white)
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

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
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
struct StyledMultiSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let mockQuestion = QuestionDTO(
            id: "roles_question",
            question: "What types of roles are you open to right now?",
            type: .multiSelect,
            placeholder: nil,
            displayOrder: 1,
            isRequired: true,
            isShareable: true,
            constraints: QuestionConstraints(
                minSelect: 1,
                maxSelect: 3,
                requireRanking: nil,
                isUsingOther: false,
                textMaxLen: nil,
                numberMin: nil,
                numberMax: nil,
                numberStep: nil
            ),
            answerOptions: [
                AnswerOptionDTO(id: "freelance", label: "Freelance / Contract", value: "freelance", displayOrder: 1),
                AnswerOptionDTO(id: "fulltime", label: "Full-time", value: "fulltime", displayOrder: 2),
                AnswerOptionDTO(id: "internship", label: "Internship", value: "internship", displayOrder: 3),
                AnswerOptionDTO(id: "mentorship", label: "Mentorship", value: "mentorship", displayOrder: 4),
                AnswerOptionDTO(id: "media", label: "Media & Entertainment", value: "media", displayOrder: 5),
                AnswerOptionDTO(id: "parttime", label: "Part-time", value: "parttime", displayOrder: 6)
            ]
        )
        
        StyledMultiSelectView(
            question: mockQuestion,
            answerManager: QuestionAnswerManager()
        )
        .preferredColorScheme(.dark)
    }
}

// MARK: - Complete Styled Onboarding View
struct CompleteStyledOnboardingView: View {
    let question: QuestionDTO
    @ObservedObject var answerManager: QuestionAnswerManager
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("OnBoarding")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Rec 1")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)
            
            // Main Content
            StyledMultiSelectView(question: question, answerManager: answerManager)
                .background(Color.black)
            
            // Continue Button
            VStack(spacing: 16) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color.black)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Complete Styled Onboarding View Preview
struct CompleteStyledOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        let mockQuestion = QuestionDTO(
            id: "roles_question",
            question: "What types of roles are you open to right now?",
            type: .multiSelect,
            placeholder: nil,
            displayOrder: 1,
            isRequired: true,
            isShareable: true,
            constraints: QuestionConstraints(
                minSelect: 1,
                maxSelect: 3,
                requireRanking: nil,
                isUsingOther: false,
                textMaxLen: nil,
                numberMin: nil,
                numberMax: nil,
                numberStep: nil
            ),
            answerOptions: [
                AnswerOptionDTO(id: "freelance", label: "Freelance / Contract", value: "freelance", displayOrder: 1),
                AnswerOptionDTO(id: "fulltime", label: "Full-time", value: "fulltime", displayOrder: 2),
                AnswerOptionDTO(id: "internship", label: "Internship", value: "internship", displayOrder: 3),
                AnswerOptionDTO(id: "mentorship", label: "Mentorship", value: "mentorship", displayOrder: 4),
                AnswerOptionDTO(id: "media", label: "Media & Entertainment", value: "media", displayOrder: 5),
                AnswerOptionDTO(id: "parttime", label: "Part-time", value: "parttime", displayOrder: 6)
            ]
        )
        
        CompleteStyledOnboardingView(
            question: mockQuestion,
            answerManager: QuestionAnswerManager(),
            onContinue: {}
        )
    }
}

// MARK: - Test View for Development
struct StyledMultiSelectTestView: View {
    @StateObject private var answerManager = QuestionAnswerManager()
    
    var body: some View {
        let mockQuestion = QuestionDTO(
            id: "test_question",
            question: "What types of roles are you open to right now?",
            type: .multiSelect,
            placeholder: nil,
            displayOrder: 1,
            isRequired: true,
            isShareable: true,
            constraints: QuestionConstraints(
                minSelect: 1,
                maxSelect: 3,
                requireRanking: nil,
                isUsingOther: true,
                textMaxLen: nil,
                numberMin: nil,
                numberMax: nil,
                numberStep: nil
            ),
            answerOptions: [
                AnswerOptionDTO(id: "freelance", label: "Freelance / Contract", value: "freelance", displayOrder: 1),
                AnswerOptionDTO(id: "fulltime", label: "Full-time", value: "fulltime", displayOrder: 2),
                AnswerOptionDTO(id: "internship", label: "Internship", value: "internship", displayOrder: 3),
                AnswerOptionDTO(id: "mentorship", label: "Mentorship", value: "mentorship", displayOrder: 4),
                AnswerOptionDTO(id: "media", label: "Media & Entertainment", value: "media", displayOrder: 5),
                AnswerOptionDTO(id: "parttime", label: "Part-time", value: "parttime", displayOrder: 6)
            ]
        )
        
        CompleteStyledOnboardingView(
            question: mockQuestion,
            answerManager: answerManager,
            onContinue: {
                print("Continue tapped!")
                print("Selected answers: \(answerManager.getAllAnswers())")
            }
        )
    }
}

// MARK: - Test View Preview
struct StyledMultiSelectTestView_Previews: PreviewProvider {
    static var previews: some View {
        StyledMultiSelectTestView()
    }
}

import SwiftUI
import UIComponentsKit

// MARK: - Styled Text Field View
struct StyledTextFieldView: View {
    let question: QuestionDTO
    @ObservedObject var answerManager: QuestionAnswerManager
    @State private var text: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ApplyBackground {
            VStack(alignment: .leading, spacing: 32) {
                // Question Title
                VStack(alignment: .leading, spacing: 16) {
                    Text(question.question)
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    // Subtitle/Description
                    Text(
                        "Adding your experience makes it easier to connect you with people who fit your goals"
                    )
                    .font(AppFont.bodySmallMedium)
                  
                    .multilineTextAlignment(.leading)
                }

                // Large Text Field
                VStack(alignment: .leading, spacing: 12) {
                    TextField(
                        "", text: $text,
                        prompt: Text(getPlaceholderText()).foregroundColor(
                            .gray), axis: .vertical
                    )
                    .font(AppFont.bodySmallMedium)
                    .foregroundColor(.white)
                    .padding(20)
                    .background(
                        ZStack {

                            // Border
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isTextFieldFocused
                                        ? AppColors.primary : Color.gray,
                                    lineWidth: isTextFieldFocused ? 2 : 1
                                )
                        }
                    )

                    .lineLimit(6...10)
                    .focused($isTextFieldFocused)
                    .onChange(of: text) { newValue in
                        answerManager.setFreeText(
                            questionId: question.id, text: newValue)
                    }

                    // Character count if there's a limit
                    if let maxLen = question.constraints.textMaxLen {
                        HStack {
                            Spacer()
                            Text("\(text.count)/\(maxLen)")
                                .font(.caption)
                                .foregroundColor(
                                    text.count > maxLen ? .red : .gray)
                        }
                    }
                }

                Spacer()
            }
           
        }
        .onAppear {
            // Load existing text if available
            if let existingText = answerManager.getTextAnswer(for: question.id)
            {
                text = existingText
            }
        }
        .onTapGesture {
            // Focus text field when tapping outside
            if !isTextFieldFocused {
                isTextFieldFocused = true
            }
        }
    }

    private func getPlaceholderText() -> String {
        if let placeholder = question.placeholder, !placeholder.isEmpty {
            return placeholder
        }
        return
            "Add a quick note — like your role, years of experience, or a key highlight (e.g. 3 years in UI design, led product launches, etc)."
    }
}

// MARK: - Complete Styled Text Field Onboarding View
struct CompleteTextFieldOnboardingView: View {
    let question: QuestionDTO
    @ObservedObject var answerManager: QuestionAnswerManager
    let onContinue: () -> Void
    @FocusState private var isTextFieldFocused: Bool

    var canContinue: Bool {
        return !question.isRequired
            || answerManager.isQuestionAnswered(question)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("OnBoarding")
                    .font(.headline)
                    .foregroundColor(.gray)

                Spacer()

                Text("Step 2")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)

            // Main Content
            StyledTextFieldView(
                question: question, answerManager: answerManager)

            // Continue Button
            VStack(spacing: 16) {
                CustomButton(
                    title: "Continue",
                    style: .primary
                ) {
                    // Dismiss keyboard first
                    isTextFieldFocused = false

                    // Add a small delay to let keyboard dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onContinue()
                    }
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

// MARK: - Alternative Compact Text Field (for shorter responses)
struct CompactStyledTextFieldView: View {
    let question: QuestionDTO
    @ObservedObject var answerManager: QuestionAnswerManager
    @State private var text: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ApplyBackground {
            VStack(alignment: .leading, spacing: 24) {
                // Question Title
                Text(question.question)
                    .font(AppFont.headingLargeSemiBold)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                // Compact Text Field
                TextField(
                    "", text: $text,
                    prompt: Text(question.placeholder ?? "Enter your answer...")
                        .foregroundColor(.gray)
                )
                .font(AppFont.bodySmallRegular)
                .foregroundColor(.white)
                .padding(16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isTextFieldFocused
                                    ? AppColors.primary : Color.clear,
                                lineWidth: isTextFieldFocused ? 2 : 0
                            )
                    }
                )
                .focused($isTextFieldFocused)
                .onChange(of: text) { newValue in
                    answerManager.setFreeText(
                        questionId: question.id, text: newValue)
                }

                // Character count
                if let maxLen = question.constraints.textMaxLen {
                    HStack {
                        Spacer()
                        Text("\(text.count)/\(maxLen)")
                            .font(.caption)
                            .foregroundColor(text.count > maxLen ? .red : .gray)
                    }
                }

                Spacer()
            }
            .padding(22)
        }
        .onAppear {
            if let existingText = answerManager.getTextAnswer(for: question.id)
            {
                text = existingText
            }
        }
    }
}

// MARK: - Test View for Text Field Development
struct StyledTextFieldTestView: View {
    @StateObject private var answerManager = QuestionAnswerManager()

    var body: some View {
        let mockQuestion = QuestionDTO(
            id: "experience_question",
            question: "Tell us a bit more about your experience",
            type: .freeText,
            placeholder:
                "Add a quick note — like your role, years of experience, or a key highlight (e.g. 3 years in UI design, led product launches, etc).",
            displayOrder: 1,
            isRequired: false,
            isShareable: true,
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
        )

        CompleteTextFieldOnboardingView(
            question: mockQuestion,
            answerManager: answerManager,
            onContinue: {
                print("Continue tapped!")
                let answers = answerManager.getAllAnswers()
                print("Text answer: \(answers.first?.textValue ?? "No text")")
            }
        )
    }
}

// MARK: - Short Text Field Test
struct CompactTextFieldTestView: View {
    @StateObject private var answerManager = QuestionAnswerManager()

    var body: some View {
        let mockQuestion = QuestionDTO(
            id: "name_question",
            question: "What's your name?",
            type: .freeText,
            placeholder: "Enter your full name",
            displayOrder: 1,
            isRequired: true,
            isShareable: false,
            constraints: QuestionConstraints(
                textMaxLen: 100
            ),
            answerOptions: []
        )

        CompactStyledTextFieldView(
            question: mockQuestion,
            answerManager: answerManager
        )
    }
}

// MARK: - Updated Dynamic Question View Integratio

// MARK: - Mock Data Extension
extension MockQuestionProvider {
    static let experienceQuestion = QuestionDTO(
        id: "experience_question",
        question: "Tell us a bit more about your experience",
        type: .freeText,
        placeholder:
            "Add a quick note — like your role, years of experience, or a key highlight (e.g. 3 years in UI design, led product launches, etc).",
        displayOrder: 3,
        isRequired: false,
        isShareable: true,
        constraints: QuestionConstraints(
            textMaxLen: 500
        ),
        answerOptions: []
    )

    static let shortTextQuestion = QuestionDTO(
        id: "name_question",
        question: "What's your current job title?",
        type: .freeText,
        placeholder: "e.g. Senior Product Designer",
        displayOrder: 4,
        isRequired: true,
        isShareable: true,
        constraints: QuestionConstraints(
            textMaxLen: 100
        ),
        answerOptions: []
    )
}

// MARK: - Previews
struct StyledTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Large text field
            StyledTextFieldTestView()
                .previewDisplayName("Large Text Field")

            // Compact text field
            CompactTextFieldTestView()
                .previewDisplayName("Compact Text Field")
        }
    }
}

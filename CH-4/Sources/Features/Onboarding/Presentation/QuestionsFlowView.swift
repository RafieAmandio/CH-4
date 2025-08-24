import SwiftUI

struct QuestionsFlowView: View {
    @EnvironmentObject private var onboardingVM: OnboardingViewModel
    @StateObject private var answerManager = QuestionAnswerManager()
    @State private var currentQuestionIndex: Int = 0
    @State private var isSubmitting: Bool = false

    var currentQuestion: QuestionDTO? {
        guard !onboardingVM.questions.isEmpty,
            currentQuestionIndex < onboardingVM.questions.count
        else {
            return nil
        }
        return onboardingVM.questions[currentQuestionIndex]
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= onboardingVM.questions.count - 1
    }

    var canProceed: Bool {
        guard let question = currentQuestion else { return false }
        return !question.isRequired
            || answerManager.isQuestionAnswered(question)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Question content with different layouts based on question type
            if let question = currentQuestion {

                ApplyBackground {
                    VStack(spacing: 0) {
                        DynamicQuestionView(
                            question: question, answerManager: answerManager)

                        Spacer()

                        CustomButton(
                            title: isSubmitting
                                ? "Submitting..."
                                : (isLastQuestion ? "Submit" : "Continue"),
                            style: .primary
                        ) {
                            handleContinueAction()
                        }
                        .disabled(!canProceed || isSubmitting)
                        .opacity((!canProceed || isSubmitting) ? 0.6 : 1.0)
                    }
                    .padding(22)

                }
            }
        }
        .navigationBarHidden(true)
    }

    private func handleContinueAction() {
        if isLastQuestion {
            submitAnswers()
        } else {
            currentQuestionIndex += 1
        }
    }

    private func submitAnswers() {
        guard !isSubmitting else { return }

        isSubmitting = true

        Task {
            do {
                let answerRequest = AnswerSubmissionRequest(
                    answers: answerManager.getAllAnswers())

                // Submit to your API through onboarding view model
                try await onboardingVM.submitAnswers(answerRequest)

                // Move to next step or complete onboarding
                await onboardingVM.moveToNextStep()

            } catch {
                // Handle error
                print("Error submitting answers: \(error)")
                // You might want to show an error alert here
            }

            isSubmitting = false
        }
    }
}

// MARK: - Alternative: Single page view with all questions (Refactored)
struct AllQuestionsView: View {
    @EnvironmentObject private var onboardingVM: OnboardingViewModel
    @StateObject private var answerManager = QuestionAnswerManager()
    @State private var isSubmitting: Bool = false

    var allRequiredQuestionsAnswered: Bool {
        onboardingVM.questions.allSatisfy { question in
            !question.isRequired || answerManager.isQuestionAnswered(question)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Questions content
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(onboardingVM.questions) { question in
                        VStack(alignment: .leading, spacing: 8) {
                            DynamicQuestionView(
                                question: question, answerManager: answerManager
                            )

                            // Required indicator
                            if question.isRequired {
                                HStack {
                                    Text("Required")
                                        .font(.caption)
                                        .foregroundColor(.red)

                                    if answerManager.isQuestionAnswered(
                                        question)
                                    {
                                        Image(
                                            systemName: "checkmark.circle.fill"
                                        )
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    }

                                    Spacer()
                                }
                            }
                        }

                        Divider()
                    }
                }
                .padding()
            }

            // Bottom continue button
            CustomButton(
                title: isSubmitting ? "Submitting..." : "Submit All Answers",
                style: .primary
            ) {
                submitAnswers()
            }
            .disabled(!allRequiredQuestionsAnswered || isSubmitting)
            .opacity(
                (!allRequiredQuestionsAnswered || isSubmitting) ? 0.6 : 1.0
            )
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private func submitAnswers() {
        guard !isSubmitting else { return }

        isSubmitting = true

        Task {
            do {
                let answerRequest = AnswerSubmissionRequest(
                    answers: answerManager.getAllAnswers())
                try await onboardingVM.submitAnswers(answerRequest)
                await onboardingVM.moveToNextStep()
            } catch {
                print("Error submitting answers: \(error)")
            }

            isSubmitting = false
        }
    }
}

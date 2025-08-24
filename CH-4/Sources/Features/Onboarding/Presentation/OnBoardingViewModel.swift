import Foundation

public final class OnboardingViewModel: ObservableObject {
    @Published var currentState: OnboardingState = .profileCompletion
    @Published var selectedGoal: GoalsCategory?
    @Published var currentQuestionIndex = 0
    @Published var answers: [String: Any] = [:]
    @Published var isCompleted = false
    @Published var goals: [GoalsCategory] = []
    @Published var errorMessage: String?
    @Published public var questions: [QuestionDTO] = []
    @Published var isLoading: Bool = false

    public let fetchGoalsUseCase: FetchGoalsUseCaseProtocol
    public let submitGoalUseCase: SubmitGoalUseCaseProtocol
    public let registerAttendeeUseCase: RegisterAttendeeUseCaseProtocol

    public init(
        fetchGoalsUseCase: FetchGoalsUseCaseProtocol,
        submitGoalUseCase: SubmitGoalUseCaseProtocol,
        registerAttendeeUseCase: RegisterAttendeeUseCaseProtocol
    ) {
        self.fetchGoalsUseCase = fetchGoalsUseCase
        self.submitGoalUseCase = submitGoalUseCase
        self.registerAttendeeUseCase = registerAttendeeUseCase
    }

    enum OnboardingState: Equatable {
        case profileCompletion
        case goalSelection
        case loading
        case questionsFlow
        case error(String)
    }

    @MainActor
    public func fetchGoals() async {
        do {
            let goals = try await fetchGoalsUseCase.execute()
            self.goals = goals
            currentState = .goalSelection
        } catch {
            print("error fetching goals: \(error)")
        }
    }

    @MainActor
    func submitAnswers(_ request: AnswerSubmissionRequest) async throws {
        // Your API call to submit answers
        print(request)
        //        try await answerSubmissionUseCase.execute(with: request)
    }

    public func handleJoinEvent(
        with payload: RegisterAttendeePayload,
        completion: @escaping (Bool?) -> Void
    ) async {
        do {
            print(payload, "PAYLOAD")
            let result = try await registerAttendeeUseCase.execute(
                with: payload)
            guard let accessToken = result.accessToken
            else {
                fatalError("Access token not found")
            }

            KeychainManager.shared.save(token: "access_token", for: accessToken)
            APIClient.shared.setAuthToken(accessToken)

        } catch {
            errorMessage = error.localizedDescription

            print("Registration failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func submitGoal(payload: SubmitGoalPayload) async throws {
        // Set loading state
        currentState = .loading

        do {
            let response = try await submitGoalUseCase.execute(with: payload)

            self.questions = response.data.questions.sortedByDisplayOrder
            
            currentState = .questionsFlow

        } catch {
            print("error submitting \(error.localizedDescription)")

            // Set error state with user-friendly message
            let errorMessage = getErrorMessage(from: error)
            currentState = .error(errorMessage)

            // Re-throw the error so caller can handle it if needed
            throw error
        }
    }

    // MARK: - Helper Methods
    private func getErrorMessage(from error: Error) -> String {
        if let onboardingError = error as? OnboardingError {
            return onboardingError.localizedDescription
        } else if error.localizedDescription.contains("network") {
            return
                "Network connection error. Please check your internet and try again."
        } else {
            return "Something went wrong. Please try again."
        }
    }

    // MARK: - Error Types
    enum OnboardingError: Error, LocalizedError {
        case noQuestionsReceived
        case invalidResponse
        case networkError

        var errorDescription: String? {
            switch self {
            case .noQuestionsReceived:
                return "No questions were found for this goal"
            case .invalidResponse:
                return "Invalid response from server"
            case .networkError:
                return "Network connection failed"
            }
        }
    }

    // ... rest of your existing logic

    func completeOnboarding() {
        // Submit answers to backend
        submitAllAnswers { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.isCompleted = true
                    // AppStateManager will handle navigation
                } else {
                    self?.currentState = .error("Failed to save your responses")
                }
            }
        }
    }

    func resetToGoalSelection() {
        currentState = .goalSelection
        selectedGoal = nil
        questions = []
        currentQuestionIndex = 0
        answers = [:]
        isCompleted = false
    }

    private func submitAllAnswers(sucess: @escaping (Bool) -> Void) {
        // API call to submit answers
        print("Submitting answers: \(answers)")
    }
}

// Add these methods to your OnBoardingViewModel

extension OnboardingViewModel {
    @MainActor
    func moveToPreviousStep() async {
        switch currentState {
        case .goalSelection:
            // Go back to profile completion
            currentState = .profileCompletion

        case .questionsFlow:
            // Go back to goal selection
            currentState = .goalSelection

        case .profileCompletion, .loading, .error:
            // Cannot go back from these states
            break
        }
    }

    @MainActor
    func moveToNextStep() async {
        switch currentState {
        case .profileCompletion:
            currentState = .goalSelection
        case .goalSelection:
            currentState = .questionsFlow

        case .questionsFlow:
            // Complete onboarding
            await completeOnboarding()

        case .loading, .error:
            break
        }
    }

    @MainActor
    private func completeOnboarding() async {
        isCompleted = true
        // Add any completion logic here
    }

    // Optional: Helper to check if back button should be shown
    var canGoBack: Bool {
        switch currentState {
        case .goalSelection, .questionsFlow:
            return true
        case .profileCompletion, .loading, .error:
            return false
        }
    }
}

// MARK: - Required Properties (add to your OnBoardingViewModel

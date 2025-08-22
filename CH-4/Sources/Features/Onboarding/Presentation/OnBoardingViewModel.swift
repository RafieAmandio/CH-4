import Foundation

public final class OnboardingViewModel: ObservableObject {
    @Published var currentState: OnboardingState = .goalSelection
    @Published var selectedGoal: GoalsCategory?
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var answers: [String: Any] = [:]
    @Published var isCompleted = false
    @Published var goals: [GoalsCategory] = []

    public let fetchGoalsUseCase: FetchGoalsUseCaseProtocol

    public init(
        fetchGoalsUseCase: FetchGoalsUseCaseProtocol
    ) {
        self.fetchGoalsUseCase = fetchGoalsUseCase
    }

    enum OnboardingState {
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
        } catch {
            print("error fetching goals: \(error)")
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

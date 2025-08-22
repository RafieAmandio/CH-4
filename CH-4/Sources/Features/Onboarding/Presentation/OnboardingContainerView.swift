import SwiftUI
import UIComponentsKit

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var viewModel = OnBoardingDIContainer.shared.makeOnBoardingViewModel()

    var body: some View {
        NavigationView {
                switch viewModel.currentState {
                case .goalSelection:
                    GoalSelectionView()
                case .loading:
                    LoadingView()
                case .questionsFlow:
                    QuestionsFlowView()
                case .error(let message):
                    ErrorView(message: message)
                }
        }
        .environmentObject(viewModel)

        .onReceive(viewModel.$isCompleted) { completed in
            if completed {
                // Notify AppStateManager that onboarding is done
                appState.completeOnboardingAndGoToUpdateProfile()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchGoals()
            }
        }
    }
}


#Preview {
    let appState = AppStateManager()
    OnboardingContainerView()
        .environmentObject(appState)
}

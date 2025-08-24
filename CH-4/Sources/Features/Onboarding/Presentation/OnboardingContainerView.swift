import SwiftUI
import UIComponentsKit

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var viewModel: OnboardingViewModel = OnBoardingDIContainer.shared.makeOnBoardingViewModel()
    
    
    var body: some View {
        NavigationView {
            switch viewModel.currentState {
            case .profileCompletion:
                UpdateProfileView(
                    isFromOnboarding: true, onProfileUpdated: nil
                )
                .environmentObject(viewModel)
            case .goalSelection:
                GoalSelectionView()
                    .environmentObject(viewModel)
            case .loading:
                LoadingView()
            case .questionsFlow:
                QuestionsFlowView()
                    .environmentObject(viewModel)
            case .error(let message):
                ErrorView(message: message)
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            Task {
                await viewModel.fetchGoals()
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AppStateManager.shared)
}

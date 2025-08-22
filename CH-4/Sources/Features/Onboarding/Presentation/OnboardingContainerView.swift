import SwiftUI
import UIComponentsKit

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var onboardingViewModel = OnboardingViewModel()

    var body: some View {
        NavigationView {
        
                switch onboardingViewModel.currentState {
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
        .environmentObject(onboardingViewModel)

        .onReceive(onboardingViewModel.$isCompleted) { completed in
            if completed {
                // Notify AppStateManager that onboarding is done
                appState.completeOnboardingAndGoToUpdateProfile()
            }
        }
    }  
}


#Preview {
    let appState = AppStateManager()
    OnboardingContainerView()
        .environmentObject(appState)
}

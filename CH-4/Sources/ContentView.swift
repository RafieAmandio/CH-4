import Foundation
import SwiftUI
import UIComponentsKit
import UIKit

struct ContentView: View {
    @EnvironmentObject var appState: AppStateManager
    var body: some View {
        // Each case is a *root* screen — no back stack
        switch appState.screen {
        case .auth:
            AuthViewContainer()

        case .appValue:
            AppValueView()
                .toolbar(.hidden, for: .navigationBar)  // just in case
                .navigationBarBackButtonHidden(true)

        case .updateProfile:
            UpdateProfileView()
                .toolbar(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden(true)

        case .homeAttendee:
            HomeAttendee()

        case .homeCreator:
            HomeCreatorView()
        case .onboarding:
            OnboardingContainerView()
        }
    }
}

#Preview("Authenticated") {
    ContentView()
        .environmentObject(
            {
                let mock = AppStateManager()
                mock.isAuthenticated = true
                return mock
            }())
}

#Preview("Unauthenticated") {
    ContentView()
        .environmentObject(
            {
                let mock = AppStateManager()
                mock.isAuthenticated = false
                return mock
            }())
}

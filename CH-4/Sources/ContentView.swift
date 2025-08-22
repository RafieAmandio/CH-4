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

private struct MiniPlayerCard: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay(Image(systemName: "music.note").font(.title2))

            VStack(alignment: .leading, spacing: 2) {
                Text("Lo-Fi Beats").font(.headline)
                Text("Artist Name").foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "play.fill")
                .font(.title3)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2, y: 1)
    }
}

private struct PlayerDetail: View {
    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 24)
                .fill(.gray.opacity(0.15))
                .frame(height: 260)
                .overlay(
                    Image(systemName: "music.quarternote.3").font(.largeTitle))

            Text("Lo-Fi Beats")
                .font(.largeTitle.weight(.semibold))

            Text("Artist Name • Album")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Now Playing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MiniPlayerCard()
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

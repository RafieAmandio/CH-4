import AuthenticationServices
import SwiftUI
import UIComponentsKit

struct SignInView: View {
    @StateObject private var viewModel: AuthViewModel
    @EnvironmentObject private var appState: AppStateManager

    @State private var currentPage = 0

    init(viewModel: AuthViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ApplyBackground {
            VStack(alignment: .center) {
                Text("Findect.")
                    .font(AppFont.interLargeBold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                ScrollingCarouselImage(
                    name: "carousel",
                    height: 160,
                    angle: -10,  // tweak this
                    pointsPerSecond: 20  // tweak speed
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                FloatingCardView()
                    .environmentObject(viewModel)
            }
            .padding(20)
            .loading(viewModel.isLoading)

        }
    }

    private var appleSignInView: some View {
        SignInWithAppleButton { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            Task {
                await viewModel.handleSignInCompletion(result)
            }
        }
        .signInWithAppleButtonStyle(.whiteOutline)
        .frame(height: 48)
        .clipShape(
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
        )
        .disabled(viewModel.isLoading)
    }

    // MARK: - Responsive Helper Functions

    private func isSmallDevice(_ geometry: GeometryProxy) -> Bool {
        geometry.size.height <= 667  // iPhone SE and smaller
    }

    private func isMediumDevice(_ geometry: GeometryProxy) -> Bool {
        geometry.size.height > 667 && geometry.size.height <= 812  // iPhone 12 mini, X, etc.
    }

    private func maxImageHeight(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        return screenHeight * 0.35
    }

    private func adaptiveSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 15 : 30
    }

    private func adaptiveTextSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 12 : 20
    }

    private func adaptiveBottomSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 30 : 60
    }

    private func safeAreaTop(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 10 : 20
    }

    private func safeAreaBottom(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 20 : 30
    }

    private func titleText(for geometry: GeometryProxy) -> String {
        if isSmallDevice(geometry) {
            return "Attend, Discover,\nNetwork!"
        } else {
            return "Attend, Discover, Network!"
        }
    }

    private func titleFont(for geometry: GeometryProxy) -> Font {
        if isSmallDevice(geometry) {
            // Use a slightly smaller font on small devices if needed
            return AppFont.headingLargeBold  // or create a custom smaller version
        } else {
            return AppFont.headingLargest
        }
    }

    private func bodyFont(for geometry: GeometryProxy) -> Font {
        if isSmallDevice(geometry) {
            return AppFont.bodySmallRegular  // Use smaller body text on small devices
        } else {
            return AppFont.bodySmallMedium
        }
    }
}

#Preview {
    SignInView(viewModel: AuthDIContainer.shared.makeAuthViewModel())
}

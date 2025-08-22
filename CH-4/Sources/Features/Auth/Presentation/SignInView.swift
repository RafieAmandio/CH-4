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
        GeometryReader { geometry in
            ApplyBackground {
                VStack(spacing: 10) {
                    // Top section with title and image
                    VStack(alignment: .leading, spacing: 50) {
                        Text("Findect.")
                            .font(AppFont.headingLargeBold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image("hero")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minHeight:300, maxHeight: 300)
                            .offset(x:18)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, safeAreaTop(for: geometry))
                    
                    Spacer()
                        .frame(height: 40)

                    // Bottom content section
                    VStack(alignment: .leading, spacing:20) {
                        Text(titleText(for: geometry))
                            .font(titleFont(for: geometry))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight:4)

                        Text("Streamline your networking process at events with Findect.")
                            .font(bodyFont(for: geometry))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight:4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Spacer before button
                    Spacer()
                        .frame(minHeight: 20, maxHeight: adaptiveBottomSpacing(for: geometry))

                    // Apple Sign In button
                    appleSignInView
                        .padding(.horizontal, 20)
               
                }
            }
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
        geometry.size.height <= 667 // iPhone SE and smaller
    }
    
    private func isMediumDevice(_ geometry: GeometryProxy) -> Bool {
        geometry.size.height > 667 && geometry.size.height <= 812 // iPhone 12 mini, X, etc.
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
            return AppFont.headingLargeBold // or create a custom smaller version
        } else {
            return AppFont.headingLargest
        }
    }
    
    private func bodyFont(for geometry: GeometryProxy) -> Font {
        if isSmallDevice(geometry) {
            return AppFont.bodySmallRegular // Use smaller body text on small devices
        } else {
            return AppFont.bodySmallMedium
        }
    }
}

#Preview {
    SignInView(viewModel: AuthDIContainer.shared.makeAuthViewModel())
}

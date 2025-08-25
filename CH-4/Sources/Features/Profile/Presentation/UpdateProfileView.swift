import SwiftUI
import UIComponentsKit

struct UpdateProfileView: View {
    @EnvironmentObject private var onBoardingViewModel: OnboardingViewModel

    @EnvironmentObject private var appState: AppStateManager
    @StateObject private var viewModel: UpdateProfileViewModel =
    ProfileDIContainer.shared.createProfileViewModel()

    let isFromOnboarding: Bool
    let onProfileUpdated: (() -> Void)?

    // Initializer to configure the context
    init(isFromOnboarding: Bool = false, onProfileUpdated: (() -> Void)? = nil)
    {
        self.isFromOnboarding = isFromOnboarding
        self.onProfileUpdated = onProfileUpdated
    }

    private func handlePostUpdateNavigation() async throws {
        if isFromOnboarding {
            let selectedEvent = appState.selectedEvent
            let registerAttendePayload = RegisterAttendeePayload(
                eventCode: selectedEvent?.code ?? "",
                name: appState.user?.name ?? "",
                email: appState.user?.email ?? "",
                professionId: (appState.user?.professionId)!,
                linkedinUsername: appState.user?.linkedinUsername ?? "",
                photoLink: appState.user?.photoUrl ?? "")
            
            await onBoardingViewModel.handleJoinEvent(
                with: registerAttendePayload
            ) { success in
                if success ?? false {
                    print("successfully joined event")
                }
            }
         
            onBoardingViewModel.currentState = .goalSelection
        } else {
            onProfileUpdated?()
        }
    }

    var body: some View {
        ApplyBackground {
            VStack(spacing: 30) {
                HeaderSectionView()
                VStack(spacing: 12) {
                    CircularImagePickerWithBinding(
                        selectedImage: $viewModel.profileImage,
                        size: 125,
                        onImageSelected: viewModel.handleImageSelection
                    )
                    if viewModel.isUploading {
                        VStack(spacing: 4) {
                            ProgressView(value: viewModel.uploadProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 100)

                            Text("Uploading...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                AppTextField(
                    text: $viewModel.name,
                    placeholder: "Name",
                    height: 51,
                    leadingIcon: Image(systemName: "person.circle.fill")
                )
                if viewModel.isLoadingProfessions {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading professions...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 51)
                } else {
                    SearchDropdown(
                        text: $viewModel.profession,
                        placeholder: "Profession",
                        professions: viewModel.professionModels,  // Use ProfessionModel array
                        onSelectProfession: { professionId in
                            viewModel.selectedProfessionId = professionId
                        }
                    )
                }

                AppTextField(
                    text: $viewModel.linkedIn,
                    placeholder: "LinkedIn (optional)",
                    height: 51,
                    leadingIcon: Image(systemName: "link.circle.fill")
                )

                Spacer()

                // Submit Button
                CustomButton(
                    title: viewModel.isUpdatingProfile
                        ? "Updating..." : "Continue",
                    style: .primary
                ) {
                    Task {
                        do {
                            // First update the profile
                            await viewModel.updateProfile()
                            // Handle navigation based on context
                            if !viewModel.showError {
                                try await handlePostUpdateNavigation()
                            }
                        } catch {
                            // You might want to show an error alert here
                            viewModel.errorMessage = error.localizedDescription
                            viewModel.showError = true
                        }
                    }
                }
                .disabled(
                    !viewModel.isFormValid || viewModel.isUpdatingProfile
                        || viewModel.isUploading
                )
                .opacity(
                    (!viewModel.isFormValid || viewModel.isUpdatingProfile
                        || viewModel.isUploading) ? 0.6 : 1.0)

                // Loading Indicator for Profile Update
            }
            .padding()
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadProfessions()
                }
            }
        }
    }
}

#Preview {
    UpdateProfileView()
        .environmentObject(AppStateManager.shared)
}

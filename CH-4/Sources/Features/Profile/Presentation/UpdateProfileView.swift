import SwiftUI
import UIComponentsKit

struct UpdateProfileView: View {
    @StateObject private var viewModel: UpdateProfileViewModel =
    ProfileDIContainer.shared.createProfileViewModel()
    
    @EnvironmentObject private var appState: AppStateManager
    
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
                            print(professionId)
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
                        await viewModel.updateProfile()
                        if !viewModel.showError {
                            appState.completeOnboardingAndGoToUpdateProfile()
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
                if viewModel.isUpdatingProfile {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Updating profile...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
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
        .environmentObject(AppStateManager())
}

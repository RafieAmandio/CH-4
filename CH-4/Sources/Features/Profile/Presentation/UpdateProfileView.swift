import SwiftUI
import UIComponentsKit

struct UpdateProfileView: View {
    @StateObject private var viewModel = UpdateProfileViewModel()
    @EnvironmentObject private var appState: AppStateManager
    
    private let professions = [
        "Software Engineer","iOS Developer","Android Developer","Data Scientist",
        "Product Manager","UI/UX Designer","Graphic Designer","Marketing Specialist",
        "Accountant","Teacher","Nurse","Doctor","Lawyer","Entrepreneur","Photographer",
        "Content Creator","Barista","Chef","Architect","Civil Engineer","Mechanical Engineer"
    ]
    
    var body: some View {
        ApplyBackground {
            VStack(spacing: 30) {
                HeaderSectionView()
                
                // Image Picker with Upload Progress
                VStack(spacing: 12) {
                    CircularImagePickerWithBinding(
                        selectedImage: $viewModel.profileImage,
                        size: 125,
                        onImageSelected: viewModel.handleImageSelection
                    )
                    
                    // Upload Progress Indicator
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
                
                // Form Fields
                AppTextField(
                    text: $viewModel.name,
                    placeholder: "Name",
                    height: 51
                )
                
                SearchDropdown(
                    text: $viewModel.profession,
                    placeholder: "Profession",
                    options: professions,
                    onSelect: { selected in
                        viewModel.profession = selected
                    }
                )
                
                AppTextField(
                    text: $viewModel.linkedIn,
                    placeholder: "LinkedIn (optional)",
                    height: 51
                )
                
                Spacer()
                
                // Submit Button
                CustomButton(
                    title: viewModel.isUpdatingProfile ? "Updating..." : "Continue",
                    style: .primary
                ) {
                    Task {
                        await viewModel.updateProfile()
                        
                        // Navigate on success (no errors)
                        if !viewModel.showError {
                            appState.completeOnboardingAndGoToUpdateProfile()
                        }
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isUpdatingProfile || viewModel.isUploading)
                .opacity((!viewModel.isFormValid || viewModel.isUpdatingProfile || viewModel.isUploading) ? 0.6 : 1.0)
                
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
        }
    }
}

#Preview {
    UpdateProfileView()
        .environmentObject(AppStateManager())
}

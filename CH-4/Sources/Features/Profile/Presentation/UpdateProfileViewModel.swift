import SwiftUI
import Combine

// MARK: - Update Profile View Model
@MainActor
class UpdateProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var profileImage: UIImage? = UIImage(named: "placeholder")
    @Published var name = ""
    @Published var profession = ""
    @Published var linkedIn = ""
    
    // MARK: - Upload State
    @Published var isUploading = false
    @Published var isUpdatingProfile = false
    @Published var uploadProgress: Double = 0.0
    @Published var profileImageURL: String?
    
    // MARK: - Error Handling
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Validation
    @Published var isFormValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
    }
    
    // MARK: - Form Validation
    private func setupValidation() {
        Publishers.CombineLatest($name, $profession)
            .map { name, profession in
                !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !profession.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .assign(to: &$isFormValid)
    }
    
    // MARK: - Image Upload
    func uploadProfileImage() async {
        guard let image = profileImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            setError("Failed to process profile image")
            return
        }
        
        isUploading = true
        uploadProgress = 0.0
        clearError()
        
        do {
            let fileName = "profiles/\(UUID().uuidString).jpg"
            
            
            uploadProgress = 0.5
            
            // Upload file
            try await SupabaseManager.shared.client.storage.from("profile-photo").upload(fileName, data: imageData)
            
            uploadProgress = 0.8
            
            // Get public URL
            let publicURL = try SupabaseManager.shared.client.storage
                .from("images")
                .getPublicURL(path: fileName)
            
            uploadProgress = 1.0
            profileImageURL = publicURL.absoluteString
            
        } catch {
            setError("Failed to upload profile image: \(error.localizedDescription)")
            uploadProgress = 0.0
        }
        
        isUploading = false
    }
    
    // MARK: - Profile Update
    func updateProfile() async {
        guard isFormValid else {
            setError("Please fill in all required fields")
            return
        }
        
        isUpdatingProfile = true
        clearError()
        
        do {
            // First upload image if there's a new one and no URL yet
            if profileImage != UIImage(named: "placeholder") && profileImageURL == nil {
                await uploadProfileImage()
            }
            
            // If image upload failed, don't proceed
            if profileImage != UIImage(named: "placeholder") && profileImageURL == nil {
                isUpdatingProfile = false
                return
            }
            
            // Update profile data
            let profileData = ProfileUpdateData(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                profession: profession.trimmingCharacters(in: .whitespacesAndNewlines),
                linkedIn: linkedIn.trimmingCharacters(in: .whitespacesAndNewlines),
                profileImageURL: profileImageURL
            )
            
            try await ProfileService.shared.updateProfile(profileData)
            
            // Success - handle navigation or success state
            print("Profile updated successfully")
            
        } catch {
            setError("Failed to update profile: \(error.localizedDescription)")
        }
        
        isUpdatingProfile = false
    }
    
    // MARK: - Image Selection Handling
    func handleImageSelection(_ image: UIImage?)  async {
        profileImage = image
        // Reset the uploaded URL since we have a new image
        profileImageURL = nil
        print("here")
        await uploadProfileImage()
        
    }
    
    // MARK: - Error Handling
    private func setError(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func clearError() {
        errorMessage = nil
        showError = false
    }
    
    // MARK: - Reset Form
    func resetForm() {
        profileImage = UIImage(named: "placeholder")
        name = ""
        profession = ""
        linkedIn = ""
        profileImageURL = nil
        clearError()
        uploadProgress = 0.0
    }
}

// MARK: - Profile Update Data Model
struct ProfileUpdateData {
    let name: String
    let profession: String
    let linkedIn: String
    let profileImageURL: String?
}

class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    func updateProfile(_ data: ProfileUpdateData) async throws {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Here you would make actual API call to update profile
        // For example, using Supabase or your backend API
        print("Updating profile with data: \(data)")
        
        // Simulate potential error
        // throw ProfileError.updateFailed
    }
}

// MARK: - Profile Service Errors
enum ProfileError: LocalizedError {
    case updateFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .updateFailed:
            return "Failed to update profile. Please try again."
        case .invalidData:
            return "Invalid profile data provided."
        }
    }
}

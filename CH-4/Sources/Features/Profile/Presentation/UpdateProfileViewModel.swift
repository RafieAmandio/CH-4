import Combine
import SwiftUI

// MARK: - Update Profile View Model
@MainActor
public class UpdateProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var profileImage: UIImage? = nil
    @Published var name = ""
    @Published var profession = ""
    @Published var linkedIn = ""

    @Published var professions: [String] = []
    @Published var isLoadingProfessions = false
    @Published var professionModels: [ProfessionModel] = []
    @Published var selectedProfessionId: UUID? = nil

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

    public init(
        fetchProfessionListUseCase: FetchProfessionListUseCaseProtocol,
        updateProfileUseCase: UpdateProfileUseCaseProtocol
    ) {
        self.fetchProfessionListUseCase = fetchProfessionListUseCase
        self.updateProfileUseCase = updateProfileUseCase
        setupValidation()
    }

    // MARK: Dependencies
    public let fetchProfessionListUseCase: FetchProfessionListUseCaseProtocol
    public let updateProfileUseCase: UpdateProfileUseCaseProtocol

    // MARK: - Form Validation
    private func setupValidation() {
        Publishers.CombineLatest($name, $selectedProfessionId)
            .map { name, selectedProfessionId in
                let nameValid = !name.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
                let professionValid = selectedProfessionId != nil
                let isValid = nameValid && professionValid
                return isValid
            }
            .assign(to: &$isFormValid)
    }

    @MainActor
    func loadProfessions() async {
        isLoadingProfessions = true
        do {
            professionModels = try await fetchProfessionListUseCase.execute()
        } catch {
            handleProfessionLoadingError(error)
        }
        isLoadingProfessions = false
    }

    private func handleProfessionLoadingError(_ error: Error) {
        showError = true
        errorMessage =
            "Unable to load professions. Please check your connection and try again."

        // Optional: Use cached or fallback data
        professionModels = getFallbackProfessions()
    }

    private func getFallbackProfessions() -> [ProfessionModel] {
        return [
            ProfessionModel(id: UUID(), name: "Software Engineer"),
            ProfessionModel(id: UUID(), name: "Product Manager"),
            // ... more options
        ]
    }
    // MARK: - Image Upload
    func uploadProfileImage() async {
        guard let image = profileImage,
            let imageData = image.jpegData(compressionQuality: 0.8)
        else {
            setError("Failed to process profile image")
            return
        }

        isUploading = true
        uploadProgress = 0.0
        clearError()

        do {
            let fileName = "profiles/\(UUID().uuidString).jpg"

            uploadProgress = 0.5

            try await SupabaseManager.shared.client.storage.from(
                "profile-photo"
            ).upload(fileName, data: imageData)

            uploadProgress = 0.8

            // Get public URL
            let publicURL = try SupabaseManager.shared.client.storage
                .from("profile-photo")
                .getPublicURL(path: fileName)

            uploadProgress = 1.0
            profileImageURL = publicURL.absoluteString

        } catch {
            setError(
                "Failed to upload profile image: \(error.localizedDescription)")
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
            if profileImage != UIImage(named: "placeholder")
                && profileImageURL == nil
            {
                await uploadProfileImage()
            }

            // If image upload failed, don't proceed
            if profileImage != UIImage(named: "placeholder")
                && profileImageURL == nil
            {
                isUpdatingProfile = false
                return
            }

            let profileData = UpdateProfilePayload(
                name: name,
                professionId: selectedProfessionId!,
                photoLink: profileImageURL ?? "",
                linkedinUsername: linkedIn
            )

            try await self.updateProfileUseCase.execute(
                payload: profileData)

        } catch {
            setError("Failed to update profile: \(error.localizedDescription)")
        }

        isUpdatingProfile = false
    }

    // MARK: - Image Selection Handling
    func handleImageSelection(_ image: UIImage?) async {
        profileImage = image
        profileImageURL = nil
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

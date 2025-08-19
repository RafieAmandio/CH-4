import Foundation

@MainActor
public final class CreateEventViewModel: ObservableObject {
    @Published var form = EventCreationForm()
    @Published var currentStep = 1
    @Published var validationErrors: [String: String] = [:]
    @Published var isLoading = false
    
    
    private let totalSteps = 3
    
    var canProceed: Bool {
        switch currentStep {
        case 1: return form.canProceedToStep2
        case 2: return form.canProceedToStep3
        case 3: return form.canCreateEvent
        default: return false
        }
    }
    
    func nextStep() {
        guard canProceed else { return }
        
        if currentStep < totalSteps + 1 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func validateCurrentStep() {
        validationErrors.removeAll()
        
        switch currentStep {
        case 1:
            if !form.isNameValid {
                validationErrors["name"] = "Event name is required"
            }
            if !form.isDescriptionValid {
                validationErrors["description"] = "Description must be at least 10 characters"
            }
        case 2:
            if form.selectedDate <= Date() {
                validationErrors["date"] = "Event date must be in the future"
            }
        case 3:
            if !form.isLocationValid {
                validationErrors["location"] = "Location is required"
            }
        default:
            break
        }
    }
    
    func createEvent() async throws {
        isLoading = true
        defer { isLoading = false }
        
        validateCurrentStep()
        guard validationErrors.isEmpty else {
            throw CreateEventError.validationFailed
        }
        
        // TODO: Add API call here
        // let event = try await eventService.createEvent(form)
        
        // For now, just simulate success
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Reset form after successful creation
        form = EventCreationForm()
        currentStep = 0
    }
}

enum CreateEventError: LocalizedError {
    case validationFailed
    
    var errorDescription: String? {
        switch self {
        case .validationFailed:
            return "Please fix validation errors before creating event"
        }
    }
}

import Foundation

struct EventCreationForm {
    var name: String = ""
    var description: String = ""
    var selectedDate: Date = Date()
    var location: String = ""
    
    // Validation computed properties
    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isDescriptionValid: Bool {
        description.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }
    
    var isLocationValid: Bool {
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var canProceedToStep2: Bool {
        isNameValid && isDescriptionValid
    }
    
    var canProceedToStep3: Bool {
        canProceedToStep2 && selectedDate > Date()
    }
    
    var canCreateEvent: Bool {
        canProceedToStep3 && isLocationValid
    }
}

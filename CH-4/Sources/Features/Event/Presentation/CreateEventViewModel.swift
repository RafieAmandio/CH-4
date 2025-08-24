import Foundation
import CoreLocation
import MapKit

struct EventLocation:Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

@MainActor
public final class CreateEventViewModel: ObservableObject {
    @Published var form = EventCreationForm()
    @Published var currentStep = 1
    @Published var validationErrors: [String: String] = [:]
    @Published var isLoading = false
    
    
    @Published var searchResults: [MKMapItem] = []
    @Published var selectedLocation: EventLocation?
    @Published var isSearching = false
    
    
    // MARK: - Dependencies
    private let createEventUseCase: CreateEventUseCaseProtocol

    public var onEventCreated: (() -> Void)?
    
    public init(
        createEventUseCase: CreateEventUseCaseProtocol
    ) {
        self.createEventUseCase = createEventUseCase
    }

    
    private let totalSteps = 3
    
    var canProceed: Bool {
        switch currentStep {
        case 1: return form.canProceedToStep2
        case 2: return form.canProceedToStep3
        case 3: return form.canCreateEvent
        default: return false
        }
    }
    
    // Update your searchForLocation method in CreateEventViewModel
    func searchForLocation(_ query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.pointOfInterest, .address] // Focus on relevant results
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                
                if let response = response {
                    // Limit to first 15 results and filter out duplicates
                    let uniqueResults = response.mapItems.prefix(15).reduce(into: [MKMapItem]()) { result, item in
                        if !result.contains(where: { existing in
                            existing.name == item.name &&
                            existing.placemark.coordinate.latitude == item.placemark.coordinate.latitude &&
                            existing.placemark.coordinate.longitude == item.placemark.coordinate.longitude
                        }) {
                            result.append(item)
                        }
                    }
                    self?.searchResults = Array(uniqueResults)
                } else {
                    self?.searchResults = []
                   
                }
            }
        }
    }
    
    func selectLocation(_ mapItem: MKMapItem) {
        let location = EventLocation(
            name: mapItem.name ?? "Unknown Location",
            coordinate: mapItem.placemark.coordinate
        )
        
        // Update both selectedLocation and form.location
        selectedLocation = location
        form.location = location  // This should now work with your EventCreationForm structure
        
        // Clear search results after selection
        searchResults = []
        
        validateCurrentStep()
    }

    private func formatAddress(from placemark: MKPlacemark) -> String {
         var addressComponents: [String] = []
         
         if let thoroughfare = placemark.thoroughfare {
             addressComponents.append(thoroughfare)
         }
         if let locality = placemark.locality {
             addressComponents.append(locality)
         }
         if let administrativeArea = placemark.administrativeArea {
             addressComponents.append(administrativeArea)
         }
         
         return addressComponents.joined(separator: ", ")
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
            if form.dateTime <= Date() {
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
    
    func createEvent() async throws -> CreateOrUpdateResult {
        isLoading = true
        defer { isLoading = false }
        
        validateCurrentStep()
        guard validationErrors.isEmpty else {
            throw CreateEventError.validationFailed
        }
        
        // TODO: Add API call here
        let event = try await createEventUseCase.execute(event: form)
        
        if event.success {
            // Reset form after successful creation
            form = EventCreationForm()
            currentStep = 1
            
            onEventCreated?()
        }
       
                
     
        return event
        
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


public struct EventCreationForm {
    var name: String = ""
    var description: String = ""
    var dateTime: Date = Date()
    var location: EventLocation = .init(name: "", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    // Validation computed properties
    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isDescriptionValid: Bool {
        description.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }
    
    var isLocationValid: Bool {
        !location.name.isEmpty
    }
    
    var canProceedToStep2: Bool {
        isNameValid && isDescriptionValid
    }
    
    var canProceedToStep3: Bool {
        canProceedToStep2 && dateTime > Date()
    }
    
    var canCreateEvent: Bool {
        canProceedToStep3 && isLocationValid
    }
}

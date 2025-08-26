import SwiftUI
import MapKit
import CoreLocation
import UIComponentsKit

struct EventLocationStepView: View {
    @ObservedObject var viewModel: CreateEventViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var showMap = false
    @State private var showInteractiveMap = false
    @State private var debounceTask: Task<Void, Never>?
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        ApplyBackground {
            VStack(alignment: .leading, spacing: 32) {
                // Step title - using same styling as StyledTextFieldView
                VStack(alignment: .leading, spacing: 16) {
                    Text("Where is the event?")
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Pick Event Location")
                        .font(AppFont.bodySmallMedium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Location search and selection - using same styling as StyledTextFieldView
                VStack(alignment: .leading, spacing: 24) {
                    // Search TextField
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(AppFont.bodySmallSemibold)
                            .foregroundColor(.white)
                        
                        TextField("Search for location", text: $searchText)
                            .font(AppFont.bodySmallRegular)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            isSearchFieldFocused
                                                ? AppColors.primary : Color.clear,
                                            lineWidth: isSearchFieldFocused ? 2 : 0
                                        )
                                }
                            )
                            .focused($isSearchFieldFocused)
                            .overlay(
                                HStack {
                                    Spacer()
                                    if viewModel.isSearching {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(AppColors.primary)
                                    }
                                }
                                .padding(.trailing, 16)
                            )
                            .onChange(of: searchText) { newValue in
                                // Cancel previous debounce task
                                debounceTask?.cancel()
                                
                                // Create new debounced task
                                debounceTask = Task {
                                    try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
                                    
                                    // Check if task wasn't cancelled
                                    if !Task.isCancelled {
                                        await MainActor.run {
                                            if !newValue.isEmpty && newValue != viewModel.form.location.name {
                                                viewModel.searchForLocation(newValue)
                                            } else if newValue.isEmpty {
                                                viewModel.searchResults = []
                                            }
                                        }
                                    }
                                }
                            }
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: useCurrentLocation) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Use Current Location")
                            }
                            .font(AppFont.bodySmallMedium)
                            .foregroundColor(AppColors.primary)
                        }
                        
                        Button(action: { showInteractiveMap = true }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Pick on Map")
                            }
                            .font(AppFont.bodySmallMedium)
                            .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Search Results List
                    if !viewModel.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(viewModel.searchResults.prefix(10), id: \.self) { mapItem in
                                    LocationResultRow(mapItem: mapItem) {
                                        selectLocationFromSearch(mapItem)
                                    }
                                    
                                    if mapItem != viewModel.searchResults.prefix(10).last {
                                        Divider()
                                            .padding(.horizontal, 12)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 300) // Limit height so it doesn't take over the screen
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    // Selected location display
                    if let selectedLocation = viewModel.selectedLocation, !selectedLocation.name.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Location")
                                .font(AppFont.bodySmallSemibold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                Text(selectedLocation.name)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                            }
                            .padding()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            )
                        }
                    }
                    
                    // Validation Error
                    if let error = viewModel.validationErrors["location"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Spacer()
            }
            .padding(22)
            .sheet(isPresented: $showMap) {
                if let selectedLocation = viewModel.selectedLocation {
                    LocationMapView(location: selectedLocation)
                }
            }
            .sheet(isPresented: $showInteractiveMap) {
                InteractiveMapLocationPicker(viewModel: viewModel)
            }
            .onAppear {
                locationManager.requestLocation()
                // Initialize searchText with current location if available
                if !viewModel.form.location.name.isEmpty {
                    searchText = viewModel.form.location.name
                }
            }
            .onDisappear {
                // Cancel debounce task when view disappears
                debounceTask?.cancel()
            }
        }
    }
    
    private func selectLocationFromSearch(_ mapItem: MKMapItem) {
        viewModel.selectLocation(mapItem)
        searchText = mapItem.name ?? ""
        
        // Update the form's location field to trigger validation
        viewModel.form.location = EventLocation(
            name: mapItem.name ?? "Unknown Location",
            coordinate: mapItem.placemark.coordinate,
            address: formatAddress(from: mapItem.placemark)
        )
        viewModel.validateCurrentStep()
    }
    
    private func useCurrentLocation() {
        guard let currentLocation = locationManager.currentLocation else {
            locationManager.requestLocation()
            return
        }
        
        // Reverse geocode to get location name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
            guard let placemark = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                let location = EventLocation(
                    name: placemark.name ?? "Current Location",
                    coordinate: currentLocation.coordinate,
                    address: formatPlacemarkAddress(placemark)
                )
                
                // Update both selectedLocation and form.location
                viewModel.selectedLocation = location
                viewModel.form.location = location
                searchText = location.name
                
                viewModel.validateCurrentStep()
            }
        }
    }
    
    private func formatPlacemarkAddress(_ placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        return components.joined(separator: ", ")
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
}

// MARK: - Supporting Views

struct LocationResultRow: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Location icon
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mapItem.name ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    if let address = formatMapItemAddress(mapItem) {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    
                    // Distance if available
                    if let distance = mapItem.placemark.location?.distance(from: CLLocation(latitude: 0, longitude: 0)) {
                        Text(formatDistance(distance))
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .contentShape(Rectangle()) // Makes entire area tappable
    }
    
    private func formatMapItemAddress(_ mapItem: MKMapItem) -> String? {
        let placemark = mapItem.placemark
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: distance)
    }
}

struct LocationMapView: View {
    let location: EventLocation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: .constant(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            ), annotationItems: [location]) { location in
                MapPin(coordinate: location.coordinate, tint: .red)
            }
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

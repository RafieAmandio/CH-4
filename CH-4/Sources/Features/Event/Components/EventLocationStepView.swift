import SwiftUI
import MapKit
import CoreLocation

struct EventLocationStepView: View {
    @ObservedObject var viewModel: CreateEventViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var showMap = false
    @State private var showInteractiveMap = false
    @State private var debounceTask: Task<Void, Never>?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Step title
            VStack(alignment: .leading, spacing: 8) {
                Text("Where is the event?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Pick Event Location")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Location search and selection
            VStack(alignment: .leading, spacing: 20) {
                // Search TextField
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Search for location", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            HStack {
                                Spacer()
                                if viewModel.isSearching {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.trailing, 8)
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
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: { showInteractiveMap = true }) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Pick on Map")
                        }
                        .foregroundColor(.green)
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
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text(selectedLocation.name)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                // Validation Error
                if let error = viewModel.validationErrors["location"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.black)
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
    
    private func selectLocationFromSearch(_ mapItem: MKMapItem) {
        viewModel.selectLocation(mapItem)
        searchText = mapItem.name ?? ""
        
        // Update the form's location field to trigger validation
        viewModel.form.location = EventLocation(
            name: mapItem.name ?? "Unknown Location",
            coordinate: mapItem.placemark.coordinate
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
                    coordinate: currentLocation.coordinate
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

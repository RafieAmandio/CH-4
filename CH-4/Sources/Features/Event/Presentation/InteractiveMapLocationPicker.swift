import SwiftUI
import MapKit
import CoreLocation

struct InteractiveMapLocationPicker: View {
    @ObservedObject var viewModel: CreateEventViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to SF
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [MKMapItem] = []
    @State private var showingSearchResults = false
    @State private var debounceTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                Map(coordinateRegion: $region,
                    interactionModes: [.pan, .zoom],
                    showsUserLocation: true,
                    annotationItems: pinLocations) { location in
                    MapPin(coordinate: location.coordinate, tint: .red)
                }
                .onTapGesture { location in
                    let coordinate = convertTapToCoordinate(location)
                    handleMapTap(at: coordinate)
                }
                
                // Search Bar at top
                VStack {
                    searchBarView
                    
                    if showingSearchResults && !searchResults.isEmpty {
                        searchResultsList
                    }
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControls
                }
                
                // Center crosshairs (optional visual aid)
                if selectedCoordinate == nil {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.red)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 30, height: 30)
                        )
                        .shadow(radius: 3)
                }
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSelectedLocation()
                    }
                    .disabled(selectedCoordinate == nil)
                }
            }
        }
        .onAppear {
            setupInitialLocation()
        }
        .onDisappear {
            debounceTask?.cancel()
        }
    }
    
    private var searchBarView: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search for a place", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: searchText) { newValue in
                        handleSearchTextChange(newValue)
                    }
                
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                        showingSearchResults = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            Button(action: centerOnUserLocation) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .frame(width: 40, height: 40)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults.prefix(8), id: \.self) { mapItem in
                    SearchResultRow(mapItem: mapItem) {
                        selectSearchResult(mapItem)
                    }
                    
                    if mapItem != searchResults.prefix(8).last {
                        Divider()
                    }
                }
            }
        }
        .frame(maxHeight: 250)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
    
    private var bottomControls: some View {
        VStack(spacing: 12) {
            if let coordinate = selectedCoordinate {
                locationInfoCard(for: coordinate)
            }
            
            HStack(spacing: 16) {
                Button("Drop Pin Here") {
                    dropPinAtCenter()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                if selectedCoordinate != nil {
                    Button("Clear Pin") {
                        selectedCoordinate = nil
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var pinLocations: [PinLocation] {
        if let coordinate = selectedCoordinate {
            return [PinLocation(coordinate: coordinate)]
        }
        return []
    }
    
    // MARK: - Helper Functions
    
    private func setupInitialLocation() {
        // Try to use current location first
        if let currentLocation = locationManager.currentLocation {
            region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // If there's already a selected location, use that
        if let existingLocation = viewModel.selectedLocation {
            region = MKCoordinateRegion(
                center: existingLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            selectedCoordinate = existingLocation.coordinate
        }
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        debounceTask?.cancel()
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms for map search
            
            if !Task.isCancelled {
                await MainActor.run {
                    if !newValue.isEmpty {
                        performSearch(newValue)
                    } else {
                        searchResults = []
                        showingSearchResults = false
                    }
                }
            }
        }
    }
    
    private func performSearch(_ query: String) {
        isSearching = true
        showingSearchResults = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        request.resultTypes = [.pointOfInterest, .address]
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                if let response = response {
                    searchResults = Array(response.mapItems.prefix(10))
                } else {
                    searchResults = []
                }
            }
        }
    }
    
    private func selectSearchResult(_ mapItem: MKMapItem) {
        let coordinate = mapItem.placemark.coordinate
        selectedCoordinate = coordinate
        
        // Move map to selected location
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        // Clear search
        searchText = mapItem.name ?? ""
        searchResults = []
        showingSearchResults = false
    }
    
    private func convertTapToCoordinate(_ tapLocation: CGPoint) -> CLLocationCoordinate2D {
        // This is a simplified conversion - actual implementation would need screen-to-map coordinate conversion
        return region.center // For now, just use center - you'd need proper coordinate conversion
    }
    
    private func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
    }
    
    private func dropPinAtCenter() {
        selectedCoordinate = region.center
    }
    
    private func centerOnUserLocation() {
        if let currentLocation = locationManager.currentLocation {
            region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        } else {
            locationManager.requestLocation()
        }
    }
    
    private func locationInfoCard(for coordinate: CLLocationCoordinate2D) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Selected Location")
                .font(.headline)
            Text("Lat: \(coordinate.latitude, specifier: "%.6f")")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Lng: \(coordinate.longitude, specifier: "%.6f")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func saveSelectedLocation() {
        guard let coordinate = selectedCoordinate else { return }
        
        // Reverse geocode to get address
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, error in
            DispatchQueue.main.async {
                let placemark = placemarks?.first
                let locationName = placemark?.name ?? "Selected Location"
                let address = formatAddress(from: placemark)
                
                let location = EventLocation(
                    name: locationName,
                    coordinate: coordinate
                )
                
                viewModel.selectedLocation = location
                viewModel.form.location = location
                viewModel.validateCurrentStep()
                
                dismiss()
            }
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark?) -> String {
        guard let placemark = placemark else { return "" }
        
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
}

// MARK: - Supporting Types and Views

struct PinLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct SearchResultRow: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mapItem.name ?? "Unknown Location")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    if let address = formatAddress(mapItem) {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAddress(_ mapItem: MKMapItem) -> String? {
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
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

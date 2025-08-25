import SwiftUI
import MapKit
import CoreLocation
import UIComponentsKit

struct InteractiveMapLocationPicker: View {
    @ObservedObject var viewModel: CreateEventViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -8.6500, longitude: 115.2167), // Default to Bali
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [MKMapItem] = []
    @State private var showingSearchResults = false
    @State private var debounceTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ApplyBackground {
            VStack(spacing: 0) {
                // Header Section
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text("Select the event location!")
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 22)
                }
                .padding(.top, 20)
                
                // Search Input
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                    
                    TextField("Input Location", text: $searchText)
                        .font(Font.custom("Urbanist", size: 17).weight(.medium))
                        .foregroundColor(.white)
                        .onChange(of: searchText) { newValue in
                            handleSearchTextChange(newValue)
                        }
                    
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                            showingSearchResults = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.13, green: 0.13, blue: 0.17))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 1)
                )
                .padding(.horizontal, 22)
                .padding(.top, 20)
                
                // Search Results
                if showingSearchResults && !searchResults.isEmpty {
                    searchResultsList
                        .padding(.horizontal, 22)
                        .padding(.top, 8)
                }
                
                // Map View
                ZStack {
                    Map(coordinateRegion: $region,
                        interactionModes: [.pan, .zoom],
                        showsUserLocation: true,
                        annotationItems: pinLocations) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            // Custom blue teardrop marker
                            VStack(spacing: 0) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(AppColors.primary)
                                
                                Circle()
                                    .fill(AppColors.primary)
                                    .frame(width: 8, height: 8)
                                    .offset(y: -2)
                            }
                        }
                    }
                    .onTapGesture { location in
                        let coordinate = convertTapToCoordinate(location)
                        handleMapTap(at: coordinate)
                    }
                    
                    // Zoom Controls (right side)
                    VStack(spacing: 12) {
                        Button(action: zoomIn) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.primary)
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: zoomOut) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.primary)
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "minus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.trailing, 16)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    // Center crosshairs (when no location selected)
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
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .onAppear {
            setupInitialLocation()
        }
        .onDisappear {
            debounceTask?.cancel()
        }
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
                            .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                    }
                }
            }
        }
        .frame(maxHeight: 250)
        .background(Color(red: 0.13, green: 0.13, blue: 0.17))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 0.5)
                .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 1)
        )
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
    
    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.span.latitudeDelta *= 0.5
            region.span.longitudeDelta *= 0.5
        }
    }
    
    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.span.latitudeDelta *= 2.0
            region.span.longitudeDelta *= 2.0
        }
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
    
    private var pinLocations: [PinLocation] {
        if let coordinate = selectedCoordinate {
            return [PinLocation(coordinate: coordinate)]
        }
        return []
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
                    .foregroundColor(AppColors.primary)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mapItem.name ?? "Unknown Location")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    if let address = formatAddress(mapItem) {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
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

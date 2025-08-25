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
    @State private var showingSearchSheet = false
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
                Button(action: {
                    showingSearchSheet = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                        
                        if let location = viewModel.selectedLocation {
                            Text(location.name.isEmpty ? "Selected Location" : location.name)
                                .font(Font.custom("Urbanist", size: 17).weight(.medium))
                                .foregroundColor(.white)
                        } else {
                            Text("Input Location")
                                .font(Font.custom("Urbanist", size: 17).weight(.medium))
                                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
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
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 22)
                .padding(.top, 20)
                
                // Map View - Using Apple's standard approach
                ZStack {
                    Map(coordinateRegion: $region,
                        interactionModes: [.pan, .zoom],
                        showsUserLocation: true,
                        annotationItems: pinLocations) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            // Standard map pin with custom styling
                            VStack(spacing: 0) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColors.primary)
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 28, height: 28)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .onTapGesture { location in
                        // Use the center of the map instead of trying to convert tap coordinates
                        selectedCoordinate = region.center
                    }
                    
                    // Center indicator when no location is selected
                    if selectedCoordinate == nil {
                        VStack(spacing: 0) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.red)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                )
                                .shadow(radius: 3)
                            
                            Text("Tap map to select location")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Standard map controls overlay
                    VStack {
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 8) {
                                // Location button
                                Button(action: centerOnUserLocation) {
                                    Image(systemName: "location.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(AppColors.primary)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                                
                                // Zoom controls
                                VStack(spacing: 4) {
                                    Button(action: zoomIn) {
                                        Image(systemName: "plus")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .frame(width: 44, height: 44)
                                            .background(AppColors.primary)
                                            .clipShape(Circle())
                                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                    
                                    Button(action: zoomOut) {
                                        Image(systemName: "minus")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .frame(width: 44, height: 44)
                                            .background(AppColors.primary)
                                            .clipShape(Circle())
                                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingSearchSheet) {
            LocationSearchSheet(
                searchText: $searchText,
                searchResults: $searchResults,
                isSearching: $isSearching,
                onLocationSelected: { mapItem in
                    selectSearchResult(mapItem)
                    showingSearchSheet = false
                }
            )
        }
        .onAppear {
            setupInitialLocation()
        }
        .onDisappear {
            debounceTask?.cancel()
        }
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
    
    private func selectSearchResult(_ mapItem: MKMapItem) {
        let coordinate = mapItem.placemark.coordinate
        selectedCoordinate = coordinate
        
        // Move map to selected location
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Update the view model
        let location = EventLocation(
            name: mapItem.name ?? "Selected Location",
            coordinate: coordinate
        )
        
        viewModel.selectedLocation = location
        viewModel.form.location = location
        viewModel.validateCurrentStep()
    }
    
    private func centerOnUserLocation() {
        if let currentLocation = locationManager.currentLocation {
            withAnimation(.easeInOut(duration: 0.5)) {
                region = MKCoordinateRegion(
                    center: currentLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        } else {
            locationManager.requestLocation()
        }
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
    
    private var pinLocations: [PinLocation] {
        if let coordinate = selectedCoordinate {
            return [PinLocation(coordinate: coordinate)]
        }
        return []
    }
}

// MARK: - Location Search Sheet
struct LocationSearchSheet: View {
    @Binding var searchText: String
    @Binding var searchResults: [MKMapItem]
    @Binding var isSearching: Bool
    let onLocationSelected: (MKMapItem) -> Void
    
    @State private var debounceTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Input
                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primary)
                    
                    TextField("Search", text: $searchText)
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
                
                // Use Current Location Option
                Button(action: {
                    // Handle current location selection
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primary)
                        
                        Text("Use my current location")
                            .font(Font.custom("Urbanist", size: 16).weight(.medium))
                            .foregroundColor(AppColors.primary)
                            .underline()
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                
                // Search Results
                if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(searchResults, id: \.self) { mapItem in
                                SearchResultRow(mapItem: mapItem) {
                                    onLocationSelected(mapItem)
                                }
                                
                                if mapItem != searchResults.last {
                                    Divider()
                                        .background(Color(red: 0.21, green: 0.21, blue: 0.21))
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                } else if !searchText.isEmpty && !isSearching {
                    // No results found
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                        
                        Text("No locations found")
                            .font(AppFont.headingMediumBold)
                            .foregroundColor(.white)
                        
                        Text("Try searching with different keywords")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 22)
                }
                
                Spacer()
            }
            .background(Color(red: 0.13, green: 0.13, blue: 0.17))
            .navigationTitle("Enter your address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .onAppear {
            // Perform initial search if there's text
            if !searchText.isEmpty {
                performSearch(searchText)
            }
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
                    }
                }
            }
        }
    }
    
    private func performSearch(_ query: String) {
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
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
                Image(systemName: "building.2.fill")
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

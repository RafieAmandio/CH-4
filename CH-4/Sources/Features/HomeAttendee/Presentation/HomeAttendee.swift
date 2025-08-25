//
//  HomeAttendee.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import CodeScanner
import SwiftUI
import UIComponentsKit

struct HomeAttendee: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject var viewModel = HomeAttendeeDIContainer.shared
        .createHomeAttendeeViewModel()

    var body: some View {
        NavigationView {
            ApplyBackground {
                VStack(spacing: 0) {
                    // Custom Toolbar at the top
                    customToolbar
                    
                    // Main Content
                    VStack(spacing: 20) {
                        // Show different content based on event status
                        if true {
                            // User has an active event
                            AttendeeRecommendationView()
                                .environmentObject(viewModel)
                        } else {
                            // No active event
                            Text("No event right now. Start networking by scanning your QR.")
                                .multilineTextAlignment(.center)
                                .font(AppFont.bodySmallBold)
                                .frame(maxWidth: 296)
                                .foregroundStyle(AppColors.gray)

                            CustomButton(title: "Scan", style: .primary, width: 116) {
                                viewModel.isShowingScanner = true
                            }
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarHidden(true) // Hide the default navigation bar
            .sheet(isPresented: $viewModel.isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    completion: viewModel.handleScan
                )
            }
            .sheet(isPresented: $viewModel.isShowingEventDetail) {
                if let eventDetail = viewModel.eventDetail {
                    EventJoinSheet(eventDetail: eventDetail) {
                        appState.screen = .onboarding
                        appState.setSelectedEvent(eventDetail)
                    }
                    .presentationDetents([.fraction(0.65)])
                }
            }
            .onAppear {
                guard appState.isInitialized else { return }
                appState.updateJoinedEventStatus()
            }
        }
    }
    
    // MARK: - Custom Toolbar
    private var customToolbar: some View {
        HStack(alignment: .top) {
            // Left side - Event info
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Event")
                    .font(AppFont.headingLargeSemiBold)
                    .foregroundColor(.white)
                
                Text(eventStatusText)
                    .font(AppFont.bodySmallSemibold)
                    .foregroundColor(eventStatusColor)
            }
            
            Spacer()
            
            // Right side - Profile button
            Button {
                // Profile action
            } label: {
                // Now we can use AsyncImage safely here!
                if let urlString = appState.user?.photoUrl,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .tint(.white)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        case .failure:
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Fallback when no user photo URL
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }

    // MARK: - Computed Properties
    private var eventStatusText: String {
        if appState.isJoinedEvent, let selectedEvent = appState.selectedEvent {
            return selectedEvent.name
        } else {
            return "No ongoing event"
        }
    }

    private var eventStatusColor: Color {
        appState.isJoinedEvent ? .white : AppColors.gray
    }
}

// MARK: - Alternative with Better Styling
struct HomeAttendeeAlternative: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject var viewModel = HomeAttendeeDIContainer.shared
        .createHomeAttendeeViewModel()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ApplyBackground {
                    VStack(spacing: 0) {
                        // Status bar spacing
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: geometry.safeAreaInsets.top)
                        
                        // Custom header
                        customHeader
                        
                        // Main content with scroll if needed
                        ScrollView {
                            VStack(spacing: 20) {
                                if appState.isJoinedEvent {
                                    AttendeeRecommendationView()
                                        .environmentObject(viewModel)
                                } else {
                                    VStack(spacing: 20) {
                                        Spacer().frame(height: 40)
                                        
                                        Text("No event right now. Start networking by scanning your QR.")
                                            .multilineTextAlignment(.center)
                                            .font(AppFont.bodySmallBold)
                                            .frame(maxWidth: 296)
                                            .foregroundStyle(AppColors.gray)

                                        CustomButton(title: "Scan", style: .primary, width: 116) {
                                            viewModel.isShowingScanner = true
                                        }
                                        
                                        Spacer().frame(height: 40)
                                    }
                                }
                            }
                            .padding(.horizontal, 22)
                        }
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    completion: viewModel.handleScan
                )
            }
            .sheet(isPresented: $viewModel.isShowingEventDetail) {
                if let eventDetail = viewModel.eventDetail {
                    EventJoinSheet(eventDetail: eventDetail) {
                        appState.screen = .onboarding
                        appState.setSelectedEvent(eventDetail)
                    }
                    .presentationDetents([.fraction(0.65)])
                }
            }
            .onAppear {
                guard appState.isInitialized else { return }
                appState.updateJoinedEventStatus()
            }
        }
    }
    
    // MARK: - Custom Header
    private var customHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Left side - Event info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Event")
                        .font(AppFont.headingLargeSemiBold)
                        .foregroundColor(.white)
                    
                    Text(eventStatusText)
                        .font(AppFont.bodySmallSemibold)
                        .foregroundColor(eventStatusColor)
                }
                
                Spacer()
                
                // Right side - Profile with smooth loading
                ProfileImageButton(imageURL: appState.user?.photoUrl)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            
            // Optional separator line
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 22)
        }
    }

    private var eventStatusText: String {
        if appState.isJoinedEvent, let selectedEvent = appState.selectedEvent {
            return selectedEvent.name
        } else {
            return "No ongoing event"
        }
    }

    private var eventStatusColor: Color {
        appState.isJoinedEvent ? .white : AppColors.gray
    }
}

// MARK: - Reusable Profile Image Button Component
struct ProfileImageButton: View {
    let imageURL: String?
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Button {
            // Profile action
        } label: {
            Group {
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.7),
                                    Color.purple.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                        )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: loadedImage)
        }
        .onAppear {
            loadImageIfNeeded()
        }
        .onChange(of: imageURL) { _ in
            loadImageIfNeeded()
        }
    }
    
    private func loadImageIfNeeded() {
        guard let imageURL = imageURL,
              !imageURL.isEmpty,
              loadedImage == nil,
              !isLoading else { return }
        
        isLoading = true
        
        Task {
            // Small delay to ensure smooth initial rendering
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            guard let url = URL(string: imageURL) else {
                await MainActor.run {
                    self.isLoading = false
                }
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let image = UIImage(data: data)
                
                await MainActor.run {
                    self.loadedImage = image
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    var appState = AppStateManager.shared
    HomeAttendee()
        .environmentObject(appState)
}

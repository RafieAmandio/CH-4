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
            VStack(spacing: 0) {
                // Custom Toolbar at the top
                customToolbarAttendee

                // Main Content
                VStack(spacing: 20) {
                    // Show different content based on event status
                    if appState.isJoinedEvent {
                        // User has an active event
                        AttendeeRecommendationView()
                            .environmentObject(viewModel)
                    } else {
                        // No active event

                        if viewModel.isLoading {
                            Text("Loading..")
                            ProgressView()
                        }
                        Text(
                            "No event right now. Start networking by scanning your QR."
                        )
                        .multilineTextAlignment(.center)
                        .font(AppFont.interMidMedium)
                        .frame(maxWidth: 296)
                        .foregroundStyle(AppColors.gray)

                        VStack(alignment: .center) {
                            CustomButton(title: "Scan", style: .newPrimary,width: 116, height:54,  content: "qrcode.viewfinder") {
                                viewModel.isShowingScanner = true
                            }

                            Text("or")
                                .font(AppFont.interMidMedium)
                                .foregroundStyle(AppColors.gray)

                            CustomButton(
                                title: "Input Code", style: .newPrimary,
                                width: 166
                            ) {
                                viewModel.isManualCodePresented = true
                            }
                        }
                        
                        CustomButton(title: "Switch role", style: .secondary, width: 116) {
                            appState.switchToCreator()
                        }
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
        // Loading overlay

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
                .hapticOnAppear(.success)
                .presentationDetents([.fraction(0.65)])
            }
        }
        .manualEventCodeSheet(
            isPresented: $viewModel.isManualCodePresented,
            viewModel: viewModel
        )
        .sheet(isPresented: $viewModel.isLogoutPresented) {
            VStack {
                CustomButton(
                    title: "Switch role", style: .secondary, width: 116
                ) {
                    appState.switchToCreator()
                }
                CustomButton(
                    title: "Sign Out", style: .primary,
                    action: {
                        appState.logout()
                    }
                )
            }
            .padding()
            .presentationDetents([.height(120)])
        }
        .onAppear {
            guard appState.isInitialized else { return }
            appState.updateJoinedEventStatus()
        }
    }

    // MARK: - Custom Toolbar
    private var customToolbarAttendee: some View {
        HStack(alignment: .top) {
            // Left side - Event info
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Event")
                    .font(AppFont.interLargeBold)
                    .foregroundStyle(LinearGradient.customGradient3)

                Text(eventStatusText)
                    .font(AppFont.interMidMedium)
                    .foregroundStyle(eventStatusBackground)
            }

            Spacer()

            // Right side - Profile button
            Button {
                viewModel.isLogoutPresented.toggle()
            } label: {
                if let urlString = appState.temp_url,
                    let url = URL(string: urlString)
                {
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
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
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

    private var eventStatusBackground: Color {
        if appState.isJoinedEvent {
            AppColors.primary
        } else {
            AppColors.offGray
        }

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
                                    Color.purple.opacity(0.7),
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
            !isLoading
        else { return }

        isLoading = true

        Task {
            // Small delay to ensure smooth initial rendering
            try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds

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

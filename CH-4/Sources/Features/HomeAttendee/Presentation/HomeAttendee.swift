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
                VStack(spacing: 20) {
                    // Show different content based on event status
                    if AppStateManager.shared.isJoinedEvent {
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
                    
//                    Button {
//                        appState.switchToCreator()
//                    } label: {
//                        Text("Switch Role")
//                    }
//                    
//                    Button {
//                        print("isJoinedEvent: \(appState.isJoinedEvent)")
//                        print("selectedEvent: \(appState.selectedEvent?.name ?? "nil")")
//                    } label: {
//                        Text("Debug Status")
//                    }
                }
                .padding(22)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Event")
                            .font(AppFont.headingLargeSemiBold)
                        
                        // Dynamic text based on event status
                        Text(eventStatusText)
                            .font(AppFont.bodySmallSemibold)
                            .foregroundColor(eventStatusColor)
                    }
                    .offset(y: 20)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Profile action
                    } label: {
                        if let urlString = appState.user?.photoUrl,
                           let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView() // loading state
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Image(systemName: "person.circle.fill") // fallback
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        }
                    }
                    .offset(y: 20)
                }
            }
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
                AppStateManager.shared.updateJoinedEventStatus()
            }
        }
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

#Preview {
    var appState = AppStateManager.shared
    HomeAttendee()
        .environmentObject(appState)
}

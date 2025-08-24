//
//  HomeAttendeeViewModel.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import CodeScanner
import Foundation

public final class HomeAttendeeViewModel: ObservableObject {
    @Published var isShowingScanner = false
    @Published var isShowingEventDetail: Bool = false
    @Published var eventDetail: EventValidateModel?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isShowError: Bool = false

    @Published var recommendations: [RecommendationModel] = []
    @Published var isLoadingRecommendations: Bool = false
    @Published var recommendationError: String?

    private var validateEventUseCase: ValidateEventUseCaseProtocol
    private var registerAttendeeUseCase: RegisterAttendeeUseCaseProtocol
    private var fetchRecommendationsUseCase: FetchRecommendationsUseCaseProtocol


    public init(
        validateEventUseCase: ValidateEventUseCaseProtocol,
        registerAttendeeUseCase: RegisterAttendeeUseCaseProtocol,
        fetchRecommendationsUseCase: FetchRecommendationsUseCaseProtocol
    ) {
        self.validateEventUseCase = validateEventUseCase
        self.registerAttendeeUseCase = registerAttendeeUseCase
        self.fetchRecommendationsUseCase = fetchRecommendationsUseCase

        Task { @MainActor in
            // Check joined status when ViewModel is initialized
            AppStateManager.shared.updateJoinedEventStatus()

            // Fetch recommendations if user is already joined to an event
            if AppStateManager.shared.isJoinedEvent {
                await self.fetchRecommendations()
            }
        }
    }

    public func onViewAppear() {
        Task { @MainActor in
            AppStateManager.shared.updateJoinedEventStatus()

            // Fetch recommendations if user joined an event
            if AppStateManager.shared.isJoinedEvent && recommendations.isEmpty {
                await fetchRecommendations()
            }
        }
    }

    public func fetchRecommendations() async {
        await MainActor.run {
            isLoadingRecommendations = true
            recommendationError = nil
        }
        guard
            let selectedEvent = await AppStateManager.shared.selectedEvent
        else {
            return
        }

        do {
            let response = try await fetchRecommendationsUseCase.execute()
        
            await MainActor.run {
                self.recommendations = response.data.recommendations.map {
                    $0.toDomain()
                }
                self.isLoadingRecommendations = false
            }
        } catch {
            await MainActor.run {
                self.recommendationError = error.localizedDescription
                self.isLoadingRecommendations = false
            }
            print(
                "Failed to fetch recommendations: \(error.localizedDescription)"
            )
        }
    }

    public func clearRecommendations() {
        recommendations = []
        recommendationError = nil
        isLoadingRecommendations = false
    }

    public func handleScan(result: Result<ScanResult, ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let result):
            Task {
                await validateEvent(with: result.string)
            }
        case .failure(let error):
            isShowError = true
            errorMessage = error.localizedDescription

        }
    }

    @MainActor
    private func validateEvent(with code: String) {
        Task {
            do {
                let data = try await validateEventUseCase.execute(code: code)
                eventDetail = data
                self.isShowingEventDetail = true
            } catch {
                isShowError = true
                errorMessage = error.localizedDescription
                print("Validation failed: \(error.localizedDescription)")
            }
        }
    }
}

//
//  HomeAttendeeViewModel.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import CodeScanner
import Foundation

@MainActor
public final class HomeAttendeeViewModel: ObservableObject {
    // MARK: - Scanner Properties
    @Published var isShowingScanner = false
    @Published var isShowingEventDetail: Bool = false
    @Published var eventDetail: EventValidateModel?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isShowError: Bool = false

    // MARK: - Recommendations Properties
    @Published var recommendations: [RecommendationModel] = []
    @Published var isLoadingRecommendations: Bool = false
    @Published var recommendationError: String?
    
    private let cacheManager = RecommendationCacheManager.shared
    @Published var lastFetchTime: Date?
    @Published var isUsingCachedData: Bool = false

    // MARK: - Use Cases
    private var validateEventUseCase: ValidateEventUseCaseProtocol
    private var registerAttendeeUseCase: RegisterAttendeeUseCaseProtocol
    private var fetchRecommendationsUseCase: FetchRecommendationsUseCaseProtocol

    // MARK: - Computed Properties
    public var hasRecommendations: Bool {
        return !recommendations.isEmpty
    }

    public var recommendationCount: Int {
        return recommendations.count
    }

 

    // MARK: - Initialization
    public init(
        validateEventUseCase: ValidateEventUseCaseProtocol,
        registerAttendeeUseCase: RegisterAttendeeUseCaseProtocol,
        fetchRecommendationsUseCase: FetchRecommendationsUseCaseProtocol
    ) {
        self.validateEventUseCase = validateEventUseCase
        self.registerAttendeeUseCase = registerAttendeeUseCase
        self.fetchRecommendationsUseCase = fetchRecommendationsUseCase

        Task { @MainActor in
            await initializeViewModel()
        }
    }

    // MARK: - Lifecycle Methods
    public func onViewAppear() {
        Task { @MainActor in
            AppStateManager.shared.updateJoinedEventStatus()

            // Fetch recommendations if user joined an event and we don't have data yet
            if AppStateManager.shared.isJoinedEvent && recommendations.isEmpty
                && recommendationError == nil
            {
                await fetchRecommendations()
            }
        }
    }


    public func fetchRecommendations(forceRefresh: Bool = false) async {
        // Prevent multiple simultaneous requests
        guard !isLoadingRecommendations else { return }

        recommendationError = nil

        guard let selectedEvent = await AppStateManager.shared.selectedEvent else {
            recommendationError = "No event selected"
            return
        }

        let eventId = selectedEvent.code

        if !forceRefresh,
            let cachedRecommendations = cacheManager.getCachedRecommendations(
                for: eventId)
        {
            self.recommendations = cachedRecommendations
            self.isUsingCachedData = true
            self.lastFetchTime =
                UserDefaults.standard.object(
                    forKey: "recommendations_last_fetch") as? Date
            print(
                "Using cached recommendations (\(cachedRecommendations.count) items)"
            )
            return
        }

        isLoadingRecommendations = true
        recommendationError = nil
        isUsingCachedData = false

        do {
            let response = try await fetchRecommendationsUseCase.execute()
            let fetchedRecommendations = response.data.recommendations.map {
                $0.toDomain()
            }

            self.recommendations = fetchedRecommendations
            self.isLoadingRecommendations = false
            self.lastFetchTime = Date()

            await cacheManager.cacheRecommendations(
                fetchedRecommendations, for: eventId)

            // Log success for debugging
            print(
                "Successfully fetched and cached \(fetchedRecommendations.count) recommendations"
            )

        } catch {
            self.recommendationError = error.localizedDescription
            self.isLoadingRecommendations = false

            if let cachedRecommendations =
                cacheManager.getCachedRecommendations(for: eventId)
            {
                self.recommendations = cachedRecommendations
                self.isUsingCachedData = true
                print("Using expired cached data as fallback")
            }

            print(
                "Failed to fetch recommendations: \(error.localizedDescription)"
            )
        }
    }

    @MainActor
    public func refreshRecommendations() async {
        recommendations = []
        recommendationError = nil
        await fetchRecommendations()
    }

    public func clearRecommendations() {
        recommendations = []
        recommendationError = nil
        isLoadingRecommendations = false
    }
    
    public var cacheInfo: String {
        if isUsingCachedData {
            if let age = cacheManager.getCacheAge() {
                let minutes = Int(age / 60)
                return "Cached \(minutes) min ago"
            }
            return "Using cached data"
        }
        return "Live data"
    }

    // MARK: - Scanner Methods
    public func handleScan(result: Result<ScanResult, ScanError>) {
        self.isShowingScanner = false

        switch result {
        case .success(let result):
            Task {
                await validateEvent(with: result.string)
            }
        case .failure(let error):
            showError(message: error.localizedDescription)
        }
    }

    // MARK: - Event Validation
    @MainActor
    private func validateEvent(with code: String) async {
        isLoading = true
        clearError()

        do {
            let data = try await validateEventUseCase.execute(code: code)
            eventDetail = data
            self.isShowingEventDetail = true
            isLoading = false

        } catch {
            showError(message: error.localizedDescription)
            isLoading = false
            print("Validation failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Error Handling
    private func showError(message: String) {
        errorMessage = message
        isShowError = true
    }

    public func clearError() {
        errorMessage = nil
        isShowError = false
    }

    // MARK: - Private Helpers
    @MainActor
    private func initializeViewModel() async {
        AppStateManager.shared.updateJoinedEventStatus()

        // Fetch recommendations if user is already joined to an event
        if AppStateManager.shared.isJoinedEvent {
            await fetchRecommendations()
        }
    }

    // MARK: - Recommendation Actions
    public func getRecommendation(by id: String) -> RecommendationModel? {
        return recommendations.first { $0.id == id }
    }

    public func removeRecommendation(by id: String) {
        recommendations.removeAll { $0.id == id }
    }
}



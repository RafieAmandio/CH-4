//
//  AppStateManager.swift
//  CH-4
//
//  Created by Dwiki on 17/08/25.
//

import Foundation

@MainActor
public class AppStateManager: ObservableObject {
    // MARK: - Singleton
    public static let shared = AppStateManager()
    
    @Published var isAuthenticated = false
    @Published var currentRole: UserRole = .attendee
    @Published var user: UserData?
    @Published private var _selectedEvent: EventValidateModel?
    @Published private var _isJoinedEvent: Bool = false
    
    // Public computed properties that trigger didSet only when needed
    public var selectedEvent: EventValidateModel? {
        get { _selectedEvent }
        set {
            _selectedEvent = newValue
            Task {
                await saveSelectedEvent()
                updateJoinedEventStatus()
            }
        }
    }
    
    public var isJoinedEvent: Bool {
        get { _isJoinedEvent }
        set {
            _isJoinedEvent = newValue
            Task {
                await saveJoinedEventStatus()
            }
        }
    }
    @Published var isInitialized: Bool = false // Track initialization state

    enum Screen {
        case auth
        case onboarding
        case updateProfile(onProfileUpdated: (() -> Void)? = nil)
        case homeAttendee
        case homeCreator
        case appValue
    }

    @Published var screen: Screen = .auth

    private var authRepository = AuthRepository(
        supabaseAuthService: SupabaseAuthService())
    
    private let persistenceQueue = DispatchQueue(label: "app-state-persistence", qos: .utility)

    enum UserRole: String, CaseIterable {
        case attendee = "attendee"
        case creator = "creator"
    }

    private func resolveScreen() {
        guard isAuthenticated || AppConfig.isDebug else {
            screen = .auth
            return
        }
        if let user, user.isFirst {
            screen = .appValue
            return
        }
        switch currentRole {
        case .attendee: screen = .homeAttendee
        case .creator: screen = .homeCreator
        }
    }

    public func setSelectedEvent(_ event: EventValidateModel?) {
        self.selectedEvent = event // This will trigger the setter
        
        if isJoinedEvent {
            fetchRecommendations()
        }
    }
    
    private enum Keys {
        static let isAuthenticated = "isAuthenticated"
        static let currentRole = "currentRole"
        static let userId = "userId"
        static let selectedEventName = "selectedEventName"
        static let selectedEventPhotoLink = "selectedEventPhotoLink"
        static let selectedEventCurrentParticipant = "selectedEventCurrentParticipant"
        static let selectedEventCode = "selectedEventCode"
        static let selectedEventEndDate = "selectedEventEndDate"
        static let isJoinedEvent = "isJoinedEvent"
    }

    func completeOnboardingAndGoToUpdateProfile(
        with newUser: UpdateProfilePayload
    ) {
        // Optional: also persist to backend that onboarding is done later
        if let u = user {
            let newUser =
                UserData(
                    id: u.id,
                    authProvider: u.authProvider,
                    email: u.email,
                    username: u.username,
                    photoUrl: newUser.photoLink,
                    linkedinUsername: newUser.linkedinUsername,
                    name: newUser.name,
                    isFirst: false,
                    isActive: u.isActive, deletedAt: u.deletedAt,
                    createdAt: u.createdAt, updatedAt: u.updatedAt,
                    professionId: newUser.professionId.uuidString
                )
            self.user = newUser
            
            Task.detached(priority: .background) {
                do {
                    try await self.authRepository.save(newUser)
                } catch {
                    print("Failed to save user: \(error)")
                }
            }
        }
    }

    func goToUpdateProfile() {
        screen = .updateProfile(onProfileUpdated: {
            self.currentRole = .attendee
            self.screen = .homeAttendee
        })
    }

    func switchToAttendee() {
        currentRole = .attendee
        screen = .homeAttendee
    }

    func switchToCreator() {
        currentRole = .creator
        screen = .homeCreator
    }

    func finishUpdateProfile() {
        // After profile is updated, go to home based on role
        switch currentRole {
        case .attendee: screen = .homeAttendee
        case .creator: screen = .homeCreator
        }
    }

    // MARK: - Async Initializer
    private init() {
        // Start with minimal blocking initialization
        Task {
            await initializeAsync()
        }
    }
    
    private func initializeAsync() async {
        // Load state in background
        await loadPersistedState()
        
        // Update UI on main thread
        await MainActor.run {
            resolveScreen()
            isInitialized = true
        }
        
        // Trigger recommendations if needed (non-blocking)
        if isJoinedEvent {
            fetchRecommendations()
        }
    }
    
    func fetchRecommendations() {
        // This will be handled by the ViewModel
        NotificationCenter.default.post(name: .shouldFetchRecommendations, object: nil)
    }

    func switchRole(to role: UserRole) {
        currentRole = role
        
        Task.detached(priority: .background) {
            UserDefaults.standard.set(role.rawValue, forKey: Keys.currentRole)
        }
    }

    func setAuthenticated(_ authenticated: Bool, user: UserData? = nil) {
        isAuthenticated = authenticated

        guard let foundedUser = user else { return }
        self.user = foundedUser
        resolveScreen()
    }

    func logout() {
        isAuthenticated = false
        user = nil
        currentRole = .attendee
        selectedEvent = nil // This will trigger the setter and clear persistence
        isJoinedEvent = false // This will trigger the setter
        
        resolveScreen()
    }
    
    // MARK: - Event Status Management
    func updateJoinedEventStatus() {
        guard let selectedEvent = _selectedEvent else {
            _isJoinedEvent = false
            return
        }
        
        // This is fast enough to stay synchronous
        _isJoinedEvent = isEventActive(endDate: selectedEvent.endDate)
    }

    private func isEventActive(endDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        
        // Try different date formats that might be used
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",  // ISO 8601 with milliseconds
            "yyyy-MM-dd'T'HH:mm:ssZ",      // ISO 8601 without milliseconds
            "yyyy-MM-dd HH:mm:ss",         // Simple format
            "yyyy-MM-dd"                   // Date only
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let eventEndDate = dateFormatter.date(from: endDate) {
                return Date() < eventEndDate
            }
        }
        
        // If we can't parse the date, assume event is not active
        return false
    }
    
    // MARK: - Async Persistence Methods
    private func saveSelectedEvent() async {
        guard let event = _selectedEvent else {
            await clearSelectedEvent()
            return
        }
        
        await withCheckedContinuation { continuation in
            persistenceQueue.async {
                UserDefaults.standard.set(event.name, forKey: Keys.selectedEventName)
                UserDefaults.standard.set(event.photoLink, forKey: Keys.selectedEventPhotoLink)
                UserDefaults.standard.set(event.currentParticipant, forKey: Keys.selectedEventCurrentParticipant)
                UserDefaults.standard.set(event.code, forKey: Keys.selectedEventCode)
                UserDefaults.standard.set(event.endDate, forKey: Keys.selectedEventEndDate)
                continuation.resume()
            }
        }
    }
    
    private func clearSelectedEvent() async {
        await withCheckedContinuation { continuation in
            persistenceQueue.async {
                UserDefaults.standard.removeObject(forKey: Keys.selectedEventName)
                UserDefaults.standard.removeObject(forKey: Keys.selectedEventPhotoLink)
                UserDefaults.standard.removeObject(forKey: Keys.selectedEventCurrentParticipant)
                UserDefaults.standard.removeObject(forKey: Keys.selectedEventCode)
                UserDefaults.standard.removeObject(forKey: Keys.selectedEventEndDate)
                continuation.resume()
            }
        }
    }
    
    private func saveJoinedEventStatus() async {
        await withCheckedContinuation { continuation in
            persistenceQueue.async {
                UserDefaults.standard.set(self._isJoinedEvent, forKey: Keys.isJoinedEvent)
                continuation.resume()
            }
        }
    }
    
    private func clearJoinedEventStatus() async {
        await withCheckedContinuation { continuation in
            persistenceQueue.async {
                UserDefaults.standard.removeObject(forKey: Keys.isJoinedEvent)
                continuation.resume()
            }
        }
    }
    
    private func loadSelectedEvent() async -> EventValidateModel? {
        return await withCheckedContinuation { continuation in
            persistenceQueue.async {
                guard let name = UserDefaults.standard.string(forKey: Keys.selectedEventName),
                      let photoLink = UserDefaults.standard.string(forKey: Keys.selectedEventPhotoLink),
                      let code = UserDefaults.standard.string(forKey: Keys.selectedEventCode),
                      let endDate = UserDefaults.standard.string(forKey: Keys.selectedEventEndDate) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let currentParticipant = UserDefaults.standard.integer(forKey: Keys.selectedEventCurrentParticipant)
                
                let event = EventValidateModel(
                    name: name,
                    photoLink: photoLink,
                    currentParticipant: currentParticipant,
                    code: code,
                    endDate: endDate
                )
                continuation.resume(returning: event)
            }
        }
    }

    private func loadPersistedState() async {
        // Load everything in background
        let (user, role, selectedEvent, joinedStatus) = await withTaskGroup(of: (UserData?, UserRole, EventValidateModel?, Bool).self) { group in
            group.addTask {
                // Load user (potentially slow)
                let user = try? await self.authRepository.getCurrentUser()
                
                // Load other UserDefaults values
                let roleString = UserDefaults.standard.string(forKey: Keys.currentRole) ?? "attendee"
                let role = UserRole(rawValue: roleString) ?? .attendee
                
                let joinedStatus = UserDefaults.standard.bool(forKey: Keys.isJoinedEvent)
                
                return (user, role, nil, joinedStatus)
            }
            
            group.addTask {
                // Load selected event
                let selectedEvent = await self.loadSelectedEvent()
                return (nil, .attendee, selectedEvent, false)
            }
            
            // Combine results
            var user: UserData?
            var role: UserRole = .attendee
            var selectedEvent: EventValidateModel?
            var joinedStatus = false
            
            for await result in group {
                if let resultUser = result.0 { user = resultUser }
                if result.1 != .attendee { role = result.1 }
                if let resultEvent = result.2 { selectedEvent = resultEvent }
                if result.3 { joinedStatus = result.3 }
            }
            
            return (user, role, selectedEvent, joinedStatus)
        }

        // Update UI on main thread
        await MainActor.run {
            self.currentRole = role
            
            if user != nil {
                setAuthenticated(true, user: user)
            }
            
            // Set values directly without triggering persistence during initialization
            self._selectedEvent = selectedEvent
            self._isJoinedEvent = joinedStatus
            
            // Validate the joined status against current time
            updateJoinedEventStatus()
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let shouldFetchRecommendations = Notification.Name("shouldFetchRecommendations")
    static let shouldClearRecommendations = Notification.Name("shouldClearRecommendations")
}

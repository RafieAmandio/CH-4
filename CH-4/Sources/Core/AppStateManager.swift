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
    @Published var selectedEvent: EventValidateModel? {
        didSet {
            saveSelectedEvent()
            updateJoinedEventStatus()
        }
    }
    @Published var isJoinedEvent: Bool = false {
        didSet {
            saveJoinedEventStatus()
        }
    }

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
        self.selectedEvent = event
        // updateJoinedEventStatus() is automatically called by didSet
        
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
            do {
                try authRepository.save(newUser)
            } catch {
                fatalError("something went wrong")
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

    // MARK: - Private Initializer
    private init() {
        loadPersistedState()
        resolveScreen()
        if isJoinedEvent {
            fetchRecommendations()
        }
    }
    
    func fetchRecommendations() {
        
    }

    func switchRole(to role: UserRole) {
        currentRole = role
        UserDefaults.standard.set(role.rawValue, forKey: Keys.currentRole)
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
        selectedEvent = nil
        isJoinedEvent = false

        // Clear persisted event data
        clearSelectedEvent()
        clearJoinedEventStatus()
        
        try? authRepository.clear()
        resolveScreen()
    }
    
    // MARK: - Event Status Management
    func updateJoinedEventStatus() {
        guard let selectedEvent = selectedEvent else {
            isJoinedEvent = false
            return
        }
        
        isJoinedEvent = isEventActive(endDate: selectedEvent.endDate)
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
    
    // MARK: - Persistence Methods
    private func saveSelectedEvent() {
        guard let event = selectedEvent else {
            clearSelectedEvent()
            return
        }
        
        UserDefaults.standard.set(event.name, forKey: Keys.selectedEventName)
        UserDefaults.standard.set(event.photoLink, forKey: Keys.selectedEventPhotoLink)
        UserDefaults.standard.set(event.currentParticipant, forKey: Keys.selectedEventCurrentParticipant)
        UserDefaults.standard.set(event.code, forKey: Keys.selectedEventCode)
        UserDefaults.standard.set(event.endDate, forKey: Keys.selectedEventEndDate)
    }
    
    private func clearSelectedEvent() {
        UserDefaults.standard.removeObject(forKey: Keys.selectedEventName)
        UserDefaults.standard.removeObject(forKey: Keys.selectedEventPhotoLink)
        UserDefaults.standard.removeObject(forKey: Keys.selectedEventCurrentParticipant)
        UserDefaults.standard.removeObject(forKey: Keys.selectedEventCode)
        UserDefaults.standard.removeObject(forKey: Keys.selectedEventEndDate)
    }
    
    private func saveJoinedEventStatus() {
        UserDefaults.standard.set(isJoinedEvent, forKey: Keys.isJoinedEvent)
    }
    
    private func clearJoinedEventStatus() {
        UserDefaults.standard.removeObject(forKey: Keys.isJoinedEvent)
    }
    
    private func loadSelectedEvent() -> EventValidateModel? {
        guard let name = UserDefaults.standard.string(forKey: Keys.selectedEventName),
              let photoLink = UserDefaults.standard.string(forKey: Keys.selectedEventPhotoLink),
              let code = UserDefaults.standard.string(forKey: Keys.selectedEventCode),
              let endDate = UserDefaults.standard.string(forKey: Keys.selectedEventEndDate) else {
            return nil
        }
        
        let currentParticipant = UserDefaults.standard.integer(forKey: Keys.selectedEventCurrentParticipant)
        
        return EventValidateModel(
            name: name,
            photoLink: photoLink,
            currentParticipant: currentParticipant,
            code: code,
            endDate: endDate
        )
    }

    private func loadPersistedState() {
        // Load user authentication state
        let user = authRepository.getCurrentUser()
        let role = UserRole(
            rawValue: UserDefaults.standard.string(forKey: Keys.currentRole) ?? "attendee"
        ) ?? .attendee

        self.currentRole = role

        if user != nil {
            setAuthenticated(true, user: user)
        }
        
        // Load selected event
        self.selectedEvent = loadSelectedEvent()
        
        // Load joined event status
        self.isJoinedEvent = UserDefaults.standard.bool(forKey: Keys.isJoinedEvent)
        
        // Validate the joined status against current time
        updateJoinedEventStatus()
    }
}

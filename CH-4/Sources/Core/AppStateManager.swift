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
    @Published var selectedEvent: EventValidateModel?

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
    }
    
    private enum Keys {
        static let isAuthenticated = "isAuthenticated"
        static let currentRole = "currentRole"
        static let userId = "userId"
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
                    photoUrl: newUser.photoLink ?? "",
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
    }

    func switchRole(to role: UserRole) {
        currentRole = role
        UserDefaults.standard.set(role.rawValue, forKey: Keys.currentRole)
    }

    func setAuthenticated(_ authenticated: Bool, user: UserData? = nil) {
        isAuthenticated = authenticated

        guard let foundedUser = user else { return }
        print(foundedUser,"FOUNDEDUSER")
        self.user = foundedUser
        resolveScreen()
    }

    func logout() {
        isAuthenticated = false
        user = nil
        currentRole = .attendee

        try? authRepository.clear()
        resolveScreen()
    }

    private func loadPersistedState() {
        let user = authRepository.getCurrentUser()
        let role =
            UserRole(
                rawValue: UserDefaults.standard.string(forKey: Keys.currentRole)
                    ?? "attendee") ?? .attendee

        self.currentRole = role

        if user != nil {
            setAuthenticated(true, user: user)
        }
    }
}

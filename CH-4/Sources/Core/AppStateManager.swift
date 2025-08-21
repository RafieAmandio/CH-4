//
//  AppStateManager.swift
//  CH-4
//
//  Created by Dwiki on 17/08/25.
//

import Foundation

@MainActor
class AppStateManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentRole: UserRole = .attendee
    @Published var user: UserData?
    
    enum Screen {
        case auth
        case onboarding
        case updateProfile
        case homeAttendee
        case homeCreator
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
            screen = .onboarding
            return
        }
        switch currentRole {
        case .attendee: screen = .homeAttendee
        case .creator: screen = .homeCreator
        }
    }
    
    private enum Keys {
        static let isAuthenticated = "isAuthenticated"
        static let currentRole = "currentRole"
        static let userId = "userId"
    }
    
    func completeOnboardingAndGoToUpdateProfile() {
        // Optional: also persist to backend that onboarding is done later
        if let u = user {
            let newUser =
            UserData(
                id: u.id, authProvider: u.authProvider, email: u.email,
                username: u.username, name: u.name,
                isFirst: false,
                isActive: u.isActive, deletedAt: u.deletedAt,
                createdAt: u.createdAt, updatedAt: u.updatedAt
            )
            self.user = newUser
            do {
                try authRepository.save(newUser)
            } catch {
                fatalError("something went wrong")
            }
        }
        currentRole = .attendee
        screen = .homeAttendee
    }
    
    func goToUpdateProfile() {
        if let u = user {
            screen = .updateProfile
        }
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
    
    init() {
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

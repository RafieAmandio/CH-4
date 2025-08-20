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
    
    private var authRepository = AuthRepository(supabaseAuthService: SupabaseAuthService())
    
    enum UserRole: String, CaseIterable {
        case attendee = "attendee"
        case creator = "creator"
    }
    
    private enum Keys {
        static let isAuthenticated = "isAuthenticated"
        static let currentRole = "currentRole"
        static let userId = "userId"
    }
    
    init() {
        loadPersistedState()
    }
    
    func switchRole(to role: UserRole) {
        currentRole = role
        UserDefaults.standard.set(role.rawValue, forKey: Keys.currentRole)
    }
    
    func setAuthenticated(_ authenticated: Bool, user: UserData? = nil) {
        isAuthenticated = authenticated
        
        guard let foundedUser = user else { return }
        
        self.user = foundedUser
    }
    
    func logout() {
        isAuthenticated = false
        user = nil
        currentRole = .attendee

        try? authRepository.clear()
    }
    
    private func loadPersistedState() {
        let user = authRepository.getCurrentUser()
        let role = UserRole(rawValue: UserDefaults.standard.string(forKey: Keys.currentRole) ?? "attendee") ?? .attendee
        
        self.currentRole = role
       
        if (user != nil) {
            setAuthenticated(true, user: user)
        }

    }
}

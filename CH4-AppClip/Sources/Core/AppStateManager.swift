//
//  AppStateManager.swift
//  CH4-AppClip
//
//  Created by Dio on 17/08/25.
//

import Foundation

@MainActor
class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    enum Screen {
        case appValue
        case updateProfile
    }
    
    @Published var screen: Screen = .appValue
    
    private init() {
        
    }
}

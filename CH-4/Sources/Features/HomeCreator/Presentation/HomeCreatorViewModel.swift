//
//  HomeCreatorViewModel.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import Foundation

@MainActor
public final class HomeCreatorViewModel: ObservableObject {
    @Published var showingProfile: Bool
    @Published var showingCreate: Bool
    
    
    public init(showingProfile: Bool, showingCreate: Bool) {
        self.showingProfile = showingProfile
        self.showingCreate = showingProfile
    }
}

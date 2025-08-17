//
//  HomeView.swift
//  CH-4
//
//  Created by Rafie Amandio F on 31/07/25.
//


import SwiftUI

struct HomeView:  View {
    @StateObject var viewModel = AuthDIContainer.shared.makeAuthViewModel()
    @EnvironmentObject var appState: AppStateManager


    var body: some View {
        VStack {
            

        }
    }
}

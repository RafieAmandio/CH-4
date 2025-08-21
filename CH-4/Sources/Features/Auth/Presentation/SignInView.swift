//
//  SignIn.swift
//  CH-4
//
//  Created by Dwiki on 11/08/25.
//

import AuthenticationServices
import SwiftUI
import UIComponentsKit

struct SignInView: View {
    @StateObject private var viewModel: AuthViewModel
    @EnvironmentObject private var appState: AppStateManager

    @State private var currentPage = 0

    init(viewModel: AuthViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppColors.offBlack)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Findect.")
                    .font(AppFont.headingLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("hero")
                    
                  
                Spacer()
                Text("Attend, Discover, Network")
                    .font(AppFont.headingLargest)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()

        }
    }

    private var appleSignInView: some View {
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 50, topTrailingRadius: 50)
                .fill(Color.white)
                .frame(maxWidth: .infinity, maxHeight: 216)

            VStack(spacing: 16) {
                SignInWithAppleButton { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    Task {
                        await viewModel.handleSignInCompletion(result)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(
                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                )
                .disabled(viewModel.isLoading)
                HStack {
                    Text("Already have an account ?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button("Sign In") {
                        print("Sign in")
                    }
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    SignInView(viewModel: AuthDIContainer.shared.makeAuthViewModel())
}

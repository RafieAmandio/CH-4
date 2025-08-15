//
//  SignIn.swift
//  CH-4
//
//  Created by Dwiki on 11/08/25.
//

import SwiftUI
import AuthenticationServices
import Supabase
import NetworkingKit
import UIComponentsKit

struct SignInView: View {
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSignedIn = false
    
    // Use the SupabaseClientProvider from NetworkingKit
    private let supabaseProvider = DefaultSupabaseClientProvider(
        url: URL(string: AppConfig.supabaseURL)!,
        anonKey: AppConfig.supabaseAnonKey
    )
    
    var body: some View {
        VStack(spacing: 20) {
            if isSignedIn {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    Text("Successfully signed in!")
                        .font(.headline)
                    Button("Sign Out") {
                        Task {
                            await signOut()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                VStack(spacing: 16) {
                    Text("Welcome to CH-4")
                        .font(AppFont.headingLarge)

                        .fontWeight(.bold)
                    
                    
                    Text("Sign in with your Apple ID to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        Task {
                            await handleSignInCompletion(result)
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .disabled(isLoading)
                    
                    if isLoading {
                        ProgressView("Signing in...")
                            .padding()
                    }
                }
            }
        }
        .padding()
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleSignInCompletion(_ result: Result<ASAuthorization, Error>) async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let authorization = try result.get()
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                throw SignInError.invalidCredential
            }
            
            guard let idToken = credential.identityToken,
                  let idTokenString = String(data: idToken, encoding: .utf8) else {
                throw SignInError.invalidToken
            }
            
            // Sign in to Supabase using the provider
            let supabaseResponse = try await supabaseProvider.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idTokenString
                )
            )
            
            // After successful Supabase sign-in, notify your backend
            await notifyBackendOfSignIn(
                userId: supabaseResponse.user.id,
                email: credential.email,
                fullName: credential.fullName
            )
            
            await MainActor.run {
                isLoading = false
                isSignedIn = true
            }
            
            print("✅ Successfully signed in with Apple ID: \(credential.user)")
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
            print("❌ Sign in failed: \(error)")
        }
    }
    
    private func signOut() async {
        do {
            try await supabaseProvider.client.auth.signOut()
            await MainActor.run {
                isSignedIn = false
            }
            print("✅ Successfully signed out")
        } catch {
            print("❌ Sign out failed: \(error)")
        }
    }
}

// Add this new function to notify your backend
private func notifyBackendOfSignIn(userId: UUID, email: String?, fullName: PersonNameComponents?) async {
    guard let backendURL = URL(string: AppConfig.backendBaseURL) else {
        print("❌ Invalid backend URL")
        return
    }
    
    var request = URLRequest(url: backendURL.appendingPathComponent("/auth/callback"))
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let payload: [String: Any] = [
        "supabase_user_id": userId.uuidString,
        "email": email ?? "",
        "full_name": [
            "given_name": fullName?.givenName ?? "",
            "family_name": fullName?.familyName ?? ""
        ],
        "sign_in_timestamp": ISO8601DateFormatter().string(from: Date())
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 {
            print("✅ Backend notified of successful sign-in")
        } else {
            print("⚠️ Backend notification failed")
        }
    } catch {
        print("❌ Failed to notify backend: \(error)")
    }
}

enum SignInError: LocalizedError {
    case invalidCredential
    case invalidToken
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid Apple ID credential received"
        case .invalidToken:
            return "Invalid identity token received"
        }
    }
}

#Preview {
    SignInView()
}

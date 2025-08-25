//
//  ProfileScreen.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 24/08/25.
//

import SwiftUI
import UIComponentsKit

// MARK: - Profile Header
struct AvatarView: View {
    @State private var selectedImage: UIImage?
    
    init() {
        if let photoUrlString = AppStateManager.shared.user?.photoUrl, let url = URL(string: photoUrlString) {
            // Async image load (sync simplified for brevity, should be improved for production)
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                _selectedImage = State(initialValue: image)
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            CircularImagePickerWithBinding(
                selectedImage: $selectedImage,
                size: 120
            ) { image in
                selectedImage = image
                print("Image selected: \(image != nil)")
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - LinkedIn Chip
struct LinkedInChip: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "link")
                    .imageScale(.medium)
                    .foregroundColor(.white)
                Text("in")
                    .font(AppFont.bodySmallSemibold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(AppColors.primary) // Blue background like LinkedIn
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Screen
struct ProfileScreen: View {
    var body: some View {
        ApplyBackground {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    IconButton(systemName: "chevron.left") { /* back */ }
                    Spacer()
                    Text("Profile")
                        .font(AppFont.bodySmallBold)
                        .foregroundColor(.white)
                    Spacer()
                    IconButton(systemName: "pencil") { /* edit */ }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 8)

                // Header
                VStack(spacing: 16) {
                    AvatarView()
                    VStack(spacing: 6) {
                        Text(AppStateManager.shared.user?.name ?? "Your Name")
                            .font(AppFont.headingLargeBold)
                            .foregroundColor(.white)
                        Text(AppStateManager.shared.user?.name ?? "Profession")
                            .font(AppFont.bodySmallMedium)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    LinkedInChip {
                        // deep link to LinkedIn
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)

                // Actions
                VStack(spacing: 12) {
                    ActionRow(title: "Attended Event", systemName: "briefcase.fill") {
                        // navigate
                    }
    
                    ActionRow(title: "Create Event", systemName: "plus") {
                        // navigate
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer(minLength: 0)

                // Logout - Using CustomButtonAdvanced for custom styling
                CustomButtonAdvanced(
                    title: "Log Out",
                    style: .danger,
                    width: 120, // Full width
                    height: 56,
                    cornerRadius: 28
                ) {
                    // logout
                }
                .cornerRadius(28)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Preview
struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileScreen()
                .preferredColorScheme(.dark)
        }
    }
}


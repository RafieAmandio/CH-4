//
//  UpdateProfileView.swift
//  CH-4
//
//  Created by Dwiki on 21/08/25.
//

import SwiftUI
import UIComponentsKit

struct UpdateProfileView: View {
    @State private var profileImage: UIImage? = UIImage(named: "placeholder")
    @State private var name = ""
    @State private var profession = ""
    @EnvironmentObject private var appState: AppStateManager

     private let professions = [
         "Software Engineer","iOS Developer","Android Developer","Data Scientist",
         "Product Manager","UI/UX Designer","Graphic Designer","Marketing Specialist",
         "Accountant","Teacher","Nurse","Doctor","Lawyer","Entrepreneur","Photographer",
         "Content Creator","Barista","Chef","Architect","Civil Engineer","Mechanical Engineer"
     ]
    
    
    var body: some View {
        ApplyBackground {
            VStack(spacing: 30) {
                HeaderSectionView()

                CircularImagePickerWithBinding(
                    selectedImage: $profileImage, size: 125)

                AppTextField(text: $name, placeholder: "Name", height: 51)
                SearchDropdown(
                    text: $profession,
                    placeholder: "Profession",
                    options: professions,
                    onSelect: { selected in
                        print("Selected:", selected)
                    }
                )

                AppTextField(text: $name, placeholder: "Linkedin (optional)", height: 51)
                
                Spacer()
                
                CustomButton(title: "Continue", style: .primary) {
                    appState.completeOnboardingAndGoToUpdateProfile()
                }

            }
            .padding()
        }

    }
}

#Preview {
    UpdateProfileView()
}

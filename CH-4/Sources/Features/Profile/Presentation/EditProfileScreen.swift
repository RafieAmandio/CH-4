//
//  EditProfileScreen.swift
//  CH-4
//
//  Created by Kenan Firmansyah on 25/08/25.
//

import SwiftUI
import UIComponentsKit

struct EditProfileScreen: View {
    @State private var name: String = AppStateManager.shared.user?.name ?? ""
//    @State private var profession: String = AppStateManager.shared.user?.profession ?? ""
    @State private var selectedImage: UIImage?
    @State private var goals: [GoalsCategory] = GoalsCategory.mockData
    @State private var selectedGoalIDs: Set<String> = []
    
    var body: some View {
        ApplyBackground {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    IconButton(systemName: "chevron.left") {
                        // dismiss
                    }
                    Spacer()
                    Text("Edit Profile")
                        .font(AppFont.bodySmallBold)
                        .foregroundColor(.white)
                    Spacer()
                    IconButton(systemName: "checkmark") {
                        // save action
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Avatar
                        CircularImagePickerWithBinding(
                            selectedImage: $selectedImage,
                            size: 120,
                            borderColor: AppColors.primary
                        ) { newImage in
                            selectedImage = newImage
                        }
                        .padding(.top, 8)
                        
                        // Name
                        AppTextField(
                            text: $name,
                            placeholder: "Full Name",
                            leadingIcon: Image(systemName: "person.fill")
                        )
                        .padding(.horizontal, 16)
                        
                        // Profession
//                        if viewModel.isLoadingProfessions {
//                            HStack {
//                                ProgressView()
//                                    .scaleEffect(0.8)
//                                Text("Loading professions...")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                            .frame(height: 51)
//                        } else {
//                            SearchDropdown(
//                                text: $viewModel.profession,
//                                placeholder: "Profession",
//                                professions: viewModel.professionModels,  // Use ProfessionModel array
//                                onSelectProfession: { professionId in
//                                    viewModel.selectedProfessionId = professionId
//                                }
//                            )
//                        }
                        
                        // Goals
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goals")
                                .font(AppFont.bodySmallSemibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 12) {
                                ForEach(goals, id: \.id) { goal in
                                    SelectableRectangleView(
                                        title: goal.name,
                                        isSelected: selectedGoalIDs.contains(goal.id),
                                        selectionMode: .multiple
                                    ) {
                                        if selectedGoalIDs.contains(goal.id) {
                                            selectedGoalIDs.remove(goal.id)
                                        } else {
                                            selectedGoalIDs.insert(goal.id)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer(minLength: 24)
                        
                        // Save Button
                        CustomButtonAdvanced(
                            title: "Save Changes",
                            style: .primary,
                            width: nil,
                            height: 56,
                            cornerRadius: 28
                        ) {
                            // Save profile
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }
}


// MARK: - Preview
struct EditProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditProfileScreen()
                .preferredColorScheme(.dark)
        }
    }
}

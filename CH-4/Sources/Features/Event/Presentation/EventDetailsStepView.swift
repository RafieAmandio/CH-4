//
//  EventDetailsStepView.swift
//  CH-4
//
//  Created by Phi Phi Pham on 22/8/2025.
//

import SwiftUI
import UIComponentsKit

struct EventDetailsStepView: View {
    @ObservedObject var viewModel: CreateEventViewModel
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isDescriptionFieldFocused: Bool

    var body: some View {
        ApplyBackground {
            VStack(alignment: .leading, spacing: 32) {
                // Step Title - using same styling as StyledTextFieldView
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's name of the Event?")
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    // Subtitle/Description - using same styling as StyledTextFieldView
                    Text("Input Event Details")
                        .font(AppFont.bodySmallMedium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Form Fields
                VStack(alignment: .leading, spacing: 24) {
                    // Name field - using Figma design template
                    HStack(spacing: 10) {
                        Text(Image(systemName: "person"))
                            .font(
                                Font.custom("SF Pro", size: 20)
                                    .weight(.semibold)
                            )
                            .foregroundColor(Color(red: 0.33, green: 0.53, blue: 0.86))

                        TextField("", text: $viewModel.form.name)
                            .font(
                                Font.custom("Urbanist", size: 17)
                                    .weight(.medium)
                            )
                            .foregroundColor(.white)
                            .placeholder(when: viewModel.form.name.isEmpty) {
                                Text("Event Name")
                                    .font(
                                        Font.custom("Urbanist", size: 17)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                            }
                            .onChange(of: viewModel.form.name) { _ in
                                viewModel.validateCurrentStep()
                            }
                        
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 26)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(red: 0.13, green: 0.13, blue: 0.17))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 1)
                    )

                    if let error = viewModel.validationErrors["name"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    // Picture/Poster input area - using same styling as StyledTextFieldView
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Picture/Poster")
                            .font(AppFont.bodySmallSemibold)
                            .foregroundColor(.white)

                        Button(action: {
                            // TODO: Implement image picker
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColors.primary)
                                
                                Text("Input Picture or Poster")
                                    .font(AppFont.bodySmallMedium)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            Color.gray,
                                            lineWidth: 1
                                        )
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

//                    // Description field - using same styling as StyledTextFieldView
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Description")
//                            .font(AppFont.bodySmallSemibold)
//                            .foregroundColor(.white)
//
//                        TextField(
//                            "", text: $viewModel.form.description,
//                            prompt: Text("Add a quick note about your event...").foregroundColor(.gray),
//                            axis: .vertical
//                        )
//                        .font(AppFont.bodySmallMedium)
//                        .foregroundColor(.white)
//                        .padding(20)
//                        .background(
//                            ZStack {
//                                // Border
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(
//                                        isDescriptionFieldFocused
//                                            ? AppColors.primary : Color.gray,
//                                        lineWidth: isDescriptionFieldFocused ? 2 : 1
//                                    )
//                            }
//                        )
//                        .lineLimit(6...10)
//                        .focused($isDescriptionFieldFocused)
//                        .onChange(of: viewModel.form.description) { _ in
//                            viewModel.validateCurrentStep()
//                        }
//
//                        if let error = viewModel.validationErrors["description"] {
//                            Text(error)
//                                .font(.caption)
//                                .foregroundColor(.red)
//                        }
//                    }
                }

                Spacer()
            }
            .padding(22)
        }
        .onTapGesture {
            // Focus text field when tapping outside
            if !isNameFieldFocused && !isDescriptionFieldFocused {
                isNameFieldFocused = false
                isDescriptionFieldFocused = false
            }
        }
    }
}

// MARK: - Placeholder Modifier Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    EventDetailsStepView(viewModel: CreateEventViewModel(createEventUseCase: MockCreateEventUseCase()))
}

// Mock for preview
private class MockCreateEventUseCase: CreateEventUseCaseProtocol {
    func execute(event: EventCreationForm) async throws -> CreateOrUpdateResult {
        return CreateOrUpdateResult(success: true, message: "Mock success", errors: [])
    }
}

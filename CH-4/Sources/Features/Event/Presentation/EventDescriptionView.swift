//
//  EventDescriptionView.swift
//  CH-4
//
//  Created by Phi Phi Pham on 24/8/2025.
//

import SwiftUI
import UIComponentsKit

struct EventDescriptionView: View {
    @ObservedObject var viewModel: CreateEventViewModel
    @FocusState private var isDescriptionFieldFocused: Bool

    var body: some View {
        ApplyBackground {
            VStack(alignment: .leading, spacing: 32) {
                // Step Title - using same styling as EventDetailsStepView
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's the event about?")
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Description Input Field - using same styling as EventDetailsStepView
                VStack(alignment: .leading, spacing: 12) {
                    TextField(
                        "Input Event Description", 
                        text: $viewModel.form.description,
                        axis: .vertical
                    )
                    .font(Font.custom("Urbanist", size: 17).weight(.medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5...10)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 200, alignment: .topLeading)
                    .background(Color(red: 0.13, green: 0.13, blue: 0.17))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 1)
                    )
                    .focused($isDescriptionFieldFocused)
                    .onTapGesture {
                        // Ensure text field gets focus when tapped
                        isDescriptionFieldFocused = true
                    }
                    .onChange(of: viewModel.form.description) { _ in
                        viewModel.validateCurrentStep()
                    }
                    .onSubmit {
                        // Hide keyboard when return is pressed
                        isDescriptionFieldFocused = false
                    }

                    if let error = viewModel.validationErrors["description"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Spacer()
            }
            .padding(22)
        }
        .onTapGesture {
            // Hide keyboard when tapping outside the text field
            isDescriptionFieldFocused = false
        }
    }
}

#Preview {
    EventDescriptionView(viewModel: CreateEventViewModel(createEventUseCase: MockCreateEventUseCase()))
}

// Mock for preview
private class MockCreateEventUseCase: CreateEventUseCaseProtocol {
    func execute(event: EventCreationForm) async throws -> CreateOrUpdateResult {
        return CreateOrUpdateResult(success: true, message: "Mock success", errors: [])
    }
}

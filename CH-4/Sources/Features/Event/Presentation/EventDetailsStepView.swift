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

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Step title
            VStack(alignment: .leading, spacing: 8) {
                Text("What's name of the Event?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Input Event Details")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Form fields
            VStack(alignment: .leading, spacing: 20) {
                // Name field with person icon
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 16))
                        
                        TextField("Event Name", text: $viewModel.form.name)
                            .foregroundColor(.white)
                            .onChange(of: viewModel.form.name) { _ in
                                viewModel.validateCurrentStep()
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    if let error = viewModel.validationErrors["name"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                // Picture/Poster input area
                VStack(alignment: .leading, spacing: 8) {
                    Text("Picture/Poster")
                        .font(.headline)
                        .foregroundColor(.white)

                    Button(action: {
                        // TODO: Implement image picker
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                            
                            Text("Input Picture or Poster")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Description field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextEditor(text: $viewModel.form.description)
                        .frame(minHeight: 100)
                        .foregroundColor(.white)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .onChange(of: viewModel.form.description) { _ in
                            viewModel.validateCurrentStep()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                    if let error = viewModel.validationErrors["description"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.black)
    }
}

#Preview {
    EventDetailsStepView(viewModel: CreateEventViewModel(createEventUseCase: MockCreateEventUseCase()))
        .background(Color.black)
}

// Mock for preview
private class MockCreateEventUseCase: CreateEventUseCaseProtocol {
    func execute(event: EventCreationForm) async throws -> CreateOrUpdateResult {
        return CreateOrUpdateResult(success: true, message: "Mock success", errors: [])
    }
}

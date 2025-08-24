//
//  EventDateStepView.swift
//  CH-4
//
//  Created by Phi Phi Pham on 22/8/2025.
//

import SwiftUI
import UIComponentsKit

struct EventDateStepView: View {
    @ObservedObject var viewModel: CreateEventViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Step title
            VStack(alignment: .leading, spacing: 8) {
                Text("When is the event?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Pick Your Event Date")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Date picker
            VStack(alignment: .leading, spacing: 16) {
                Text("Event Date")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                DatePicker(
                    "Event Date", selection: $viewModel.form.dateTime,
                    in: Date()..., displayedComponents: [.date]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .onChange(of: viewModel.form.dateTime) { _ in
                    viewModel.validateCurrentStep()
                }
                .padding(.horizontal, 20)
            }

            if let error = viewModel.validationErrors["date"] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
            }

            Spacer()
        }
        .background(Color.black)
    }
}

#Preview {
    EventDateStepView(viewModel: CreateEventViewModel(createEventUseCase: MockCreateEventUseCase()))
        .background(Color.black)
}

// Mock for preview
private class MockCreateEventUseCase: CreateEventUseCaseProtocol {
    func execute(event: EventCreationForm) async throws -> CreateOrUpdateResult {
        return CreateOrUpdateResult(success: true, message: "Mock success", errors: [])
    }
}

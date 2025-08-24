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
        ApplyBackground {
            VStack(alignment: .leading, spacing: 32) {
                // Step Title - using same styling as StyledTextFieldView
                VStack(alignment: .leading, spacing: 16) {
                    Text("When is the event?")
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Pick Your Event Date")
                        .font(AppFont.bodySmallMedium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Date picker - using same styling as StyledTextFieldView
                VStack(alignment: .leading, spacing: 12) {
                    Text("Event Date")
                        .font(AppFont.bodySmallSemibold)
                        .foregroundColor(.white)

                    DatePicker(
                        "Event Date", selection: $viewModel.form.dateTime,
                        in: Date()..., displayedComponents: [.date]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .onChange(of: viewModel.form.dateTime) { _ in
                        viewModel.validateCurrentStep()
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                        }
                    )
                }

                if let error = viewModel.validationErrors["date"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding(22)
        }
    }
}

#Preview {
    EventDateStepView(viewModel: CreateEventViewModel(createEventUseCase: MockCreateEventUseCase()))
}

// Mock for preview
private class MockCreateEventUseCase: CreateEventUseCaseProtocol {
    func execute(event: EventCreationForm) async throws -> CreateOrUpdateResult {
        return CreateOrUpdateResult(success: true, message: "Mock success", errors: [])
    }
}

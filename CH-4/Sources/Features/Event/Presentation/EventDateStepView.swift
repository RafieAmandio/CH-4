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
        VStack(alignment: .leading, spacing: 20) {
            Text("Pick Your Event Date")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            DatePicker(
                "Event Date", selection: $viewModel.form.dateTime,
                in: Date()..., displayedComponents: [.date]
            )
            .datePickerStyle(WheelDatePickerStyle())
            .onChange(of: viewModel.form.dateTime) { _ in
                viewModel.validateCurrentStep()
            }

            if let error = viewModel.validationErrors["date"] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    CreateEventView()
}

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
        VStack(alignment: .leading, spacing: 20) {
            Text("Input Event Details")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)

                    TextField("Event name", text: $viewModel.form.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: viewModel.form.name) { _ in
                            viewModel.validateCurrentStep()
                        }

                    if let error = viewModel.validationErrors["name"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)

                    TextEditor(text: $viewModel.form.description)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: viewModel.form.description) { _ in
                            viewModel.validateCurrentStep()
                        }

                    if let error = viewModel.validationErrors["description"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    CreateEventView()
}

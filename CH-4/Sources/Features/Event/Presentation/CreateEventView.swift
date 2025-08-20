//
//  CreateEventView.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import SwiftUI
import UIComponentsKit

struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: CreateEventViewModel = EventDIContainer.shared
        .createEventViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 30) {
                ProgressIndicator(
                    totalSteps: 3, currentStep: viewModel.currentStep,
                    spacing: 10)
                Text("Input Event Details")
                    .font(AppFont.headingLarge)
                stepContent

                Spacer()
                bottomButton

            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onTapGesture(perform: hideKeyboard)
        }

    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
            for: nil)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 1:
            EventDetailsStepView(viewModel: viewModel)
        case 2:
            EventDateStepView(viewModel: viewModel)
        case 3:
            EventLocationStepView(viewModel: viewModel)
        default:
            EventDetailsStepView(viewModel: viewModel)
        }
    }

    private var bottomButton: some View {
        Button(action: {
            if viewModel.currentStep < 3 {
                viewModel.nextStep()
            } else {
                // Create event logic
                Task {
                    do {
                        let createdEvent = try await viewModel.createEvent()
                        
                        if createdEvent.success {
                            presentationMode.wrappedValue.dismiss()
                        }
    
                    } catch {
                        print("Error creating event: \(error)")
                    }
                }
            }
        }) {
            Text(viewModel.currentStep < 3 ? "Continue" : "Create Event")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.canProceed ? Color.blue : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!viewModel.canProceed)
        .padding()
    }
}

#Preview {
    CreateEventView()
}

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

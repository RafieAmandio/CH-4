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
            ApplyBackground {
                VStack(spacing: 0) {
                    // StepNavBar with progress indicator
                    StepNavBar(
                        title: "Create Event",
                        totalSteps: 4,
                        currentStep: viewModel.currentStep,
                        onBack: {
                            if viewModel.currentStep > 1 {
                                viewModel.previousStep()
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        },
                        onNext: {
                            if viewModel.currentStep < 4 && viewModel.canProceed {
                                viewModel.nextStep()
                            }
                        },
                        canGoBack: true,
                        canGoNext: viewModel.currentStep < 4 && viewModel.canProceed
                    )
                    // Main content area
                    VStack(spacing: 0) {
                        // Step-specific content
                        stepContent
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        // Bottom action button
                        bottomButton
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                }
                .onTapGesture(perform: hideKeyboard)
            }
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
            EventDescriptionView(viewModel: viewModel)
        case 3:
            EventDateStepView(viewModel: viewModel)
        case 4:
            InteractiveMapLocationPicker(viewModel: viewModel)
        default:
            EventDetailsStepView(viewModel: viewModel)
        }
    }

    private var bottomButton: some View {
        Button(action: {
            if viewModel.currentStep < 4 {
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
            Text(viewModel.currentStep < 4 ? "Continue" : "Create Event")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.canProceed ? Color.blue : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!viewModel.canProceed)
    }
}

#Preview {
    CreateEventView()
}





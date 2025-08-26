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
    @State private var showingStartDatePicker = false
    @State private var showingEndDatePicker = false
    
    var body: some View {
        ApplyBackground {
            VStack(alignment: .leading, spacing: 32) {
                // Step Title
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pick your event date!")
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Date Input Fields
                VStack(alignment: .leading, spacing: 20) {
                    // Start Date
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            showingStartDatePicker = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primary)
                                
                                Text(formatStartDate())
                                    .font(Font.custom("Urbanist", size: 17).weight(.medium))
                                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.13, green: 0.13, blue: 0.17))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Blue line indicator
                        Rectangle()
                            .fill(AppColors.primary)
                            .frame(height: 2)
                            .frame(maxWidth: 20)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // End Date
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            showingEndDatePicker = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primary)
                                
                                Text(formatEndDate())
                                    .font(Font.custom("Urbanist", size: 17).weight(.medium))
                                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.13, green: 0.13, blue: 0.17))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 22)
        }
        .sheet(isPresented: $showingStartDatePicker) {
            DatePickerSheet(
                date: $viewModel.form.startDateTime,
                minimumDate: Date(),
                title: "Select Start Date"
            )
            .onDisappear {
                // Ensure end date is after start date
                if viewModel.form.endDateTime <= viewModel.form.startDateTime {
                    viewModel.form.endDateTime = viewModel.form.startDateTime.addingTimeInterval(3600)
                }
                viewModel.validateCurrentStep()
            }
        }
        .sheet(isPresented: $showingEndDatePicker) {
            DatePickerSheet(
                date: $viewModel.form.endDateTime,
                minimumDate: viewModel.form.startDateTime.addingTimeInterval(60),
                title: "Select End Date"
            )
            .onDisappear {
                viewModel.validateCurrentStep()
            }
        }
        .onAppear {
            // Initialize with current dates if not set
            if viewModel.form.startDateTime == Date() {
                viewModel.form.startDateTime = Date()
                viewModel.form.endDateTime = Date().addingTimeInterval(3600)
            }
        }
    }
    
    private func formatStartDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, h:mm a"
        return formatter.string(from: viewModel.form.startDateTime)
    }
    
    private func formatEndDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, h:mm a"
        return formatter.string(from: viewModel.form.endDateTime)
    }
}

// MARK: - Date Picker Sheet Component
struct DatePickerSheet: View {
    @Binding var date: Date
    let minimumDate: Date
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                DatePicker(
                    "Select Date",
                    selection: $date,
                    in: minimumDate...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding(.horizontal, 20)
                
                Spacer()
                
                HStack(spacing: 100) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.primary)
                    .cornerRadius(8)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
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

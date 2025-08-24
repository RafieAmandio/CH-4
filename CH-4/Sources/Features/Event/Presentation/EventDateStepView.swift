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
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // Default to 1 hour later
    @State private var showingStartDatePicker = false
    @State private var showingEndDatePicker = false
    
    var body: some View {
        ApplyBackground {
            VStack(spacing: 0) {
                // Header with progress indicator
                VStack(spacing: 16) {
                    Text("Create Event")
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Progress indicator
                    HStack(spacing: 16) {
                        ForEach(1...4, id: \.self) { step in
                            Rectangle()
                                .fill(step == 3 ? AppColors.primary : Color.white.opacity(0.35))
                                .frame(height: 4)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)

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
                                    
                                    Text(formatDateRange(startDate, endDate))
                                        .font(Font.custom("Urbanist", size: 17).weight(.medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(20)
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
                                .frame(maxWidth: .infinity)
                        }
                        
                        // End Date
                        Button(action: {
                            showingEndDatePicker = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primary)
                                
                                Text("End Date")
                                    .font(Font.custom("Urbanist", size: 17).weight(.medium))
                                    .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                                
                                Spacer()
                            }
                            .padding(20)
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

                    Spacer()
                }
                .padding(.horizontal, 22)
            }
        }
        .sheet(isPresented: $showingStartDatePicker) {
            DatePickerSheet(
                title: "Select Start Date",
                date: $startDate,
                onDateSelected: { date in
                    startDate = date
                    // Ensure end date is after start date
                    if endDate <= startDate {
                        endDate = startDate.addingTimeInterval(3600)
                    }
                    updateViewModelDates()
                }
            )
        }
        .sheet(isPresented: $showingEndDatePicker) {
            DatePickerSheet(
                title: "Select End Date",
                date: $endDate,
                minimumDate: startDate,
                onDateSelected: { date in
                    endDate = date
                    updateViewModelDates()
                }
            )
        }
        .onAppear {
            // Initialize with current dates if not set
            if viewModel.form.startDateTime == Date() {
                startDate = Date()
                endDate = Date().addingTimeInterval(3600)
                updateViewModelDates()
            } else {
                startDate = viewModel.form.startDateTime
                endDate = viewModel.form.endDateTime
            }
        }
    }
    
    private func updateViewModelDates() {
        viewModel.form.startDateTime = startDate
        viewModel.form.endDateTime = endDate
        viewModel.validateCurrentStep()
    }
    
    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = yearFormatter.string(from: start)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let time = timeFormatter.string(from: start)
        
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return "\(startString) \(year), \(time)"
        } else {
            return "\(startString) - \(endString) \(year), \(time)"
        }
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    let title: String
    @Binding var date: Date
    var minimumDate: Date?
    let onDateSelected: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                DatePicker(
                    "Select Date",
                    selection: $date,
                    in: (minimumDate ?? Date())...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDateSelected(date)
                        dismiss()
                    }
                }
            }
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

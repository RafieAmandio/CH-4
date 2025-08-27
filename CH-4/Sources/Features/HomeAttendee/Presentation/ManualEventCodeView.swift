import SwiftUI
import UIComponentsKit

struct ManualEventCodeView: View {
    @ObservedObject var viewModel: HomeAttendeeViewModel
    @FocusState private var isInputActive: Bool
    
    private let maxDigits = 6
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
            
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Input Your Event Code")
                        .font(AppFont.inter30Bold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Please enter your event code to access and join the session.")
                        .font(AppFont.interMidMedium)
                        .foregroundStyle(AppColors.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Custom digit input boxes
                HStack(spacing: 12) {
                    ForEach(0..<maxDigits, id: \.self) { index in
                        DigitBox(
                            digit: digitAt(index: index),
                            isActive: isInputActive && index == (viewModel.codeText?.count ?? 0)
                        )
                    }
                }
                
                // Hidden TextField for input handling
                TextField("", text: Binding(
                    get: { viewModel.codeText ?? "" },
                    set: { newValue in
                        // Limit to maxDigits and numbers only
                        let filtered = String(newValue.prefix(maxDigits).filter { $0.isNumber })
                        viewModel.codeText = filtered.isEmpty ? nil : filtered
                    }
                ))
                .keyboardType(.numberPad)
                .focused($isInputActive)
                .opacity(0)
                .frame(height: 0)
                
                Spacer()
                
                // Join button
                CustomButton(
                    title: "Join",
                    style: .newPrimary
                ) {
                    if let code = viewModel.codeText,
                       !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Task {
                            await viewModel.validateEventFromManualCode(
                                code.trimmingCharacters(in: .whitespacesAndNewlines)
                            )
                        }
                    }
                }
                .disabled(
                    (viewModel.codeText?.count ?? 0) < maxDigits ||
                    viewModel.codeText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false
                )
            }
            .padding(20)
        }
        .onTapGesture {
            isInputActive = true
        }
        .onAppear {
            // Auto-focus when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInputActive = true
            }
        }
    }
    
    private func digitAt(index: Int) -> String {
        let codeText = viewModel.codeText ?? ""
        if index < codeText.count {
            return String(codeText[codeText.index(codeText.startIndex, offsetBy: index)])
        }
        return ""
    }
}

struct DigitBox: View {
    let digit: String
    let isActive: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(width: 45, height: 55)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isActive ? Color.blue : Color(.systemGray4),
                            lineWidth: isActive ? 2 : 1
                        )
                )
            
            if !digit.isEmpty {
                Text(digit)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
            } else if isActive {
                // Blinking cursor
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 2, height: 20)
                    .opacity(0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.8).repeatForever(),
                        value: isActive
                    )
            }
        }
    }
}

// Usage in your sheet
extension View {
    func manualEventCodeSheet(
        isPresented: Binding<Bool>,
        viewModel: HomeAttendeeViewModel
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            ManualEventCodeView(viewModel: viewModel)
                .presentationDetents([.height(350)])
        }
    }
}

#Preview {
    // Create a mock view model for preview
    struct PreviewWrapper: View {
        @StateObject private var mockViewModel = {
            let vm = HomeAttendeeDIContainer.shared.createHomeAttendeeViewModel()
            return vm
        }()
        
        var body: some View {
            ManualEventCodeView(viewModel: mockViewModel)
        }
    }
    
    return PreviewWrapper()
}

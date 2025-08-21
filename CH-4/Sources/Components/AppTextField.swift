import SwiftUI

struct AppTextField: View {
    @Binding var text: String
    var placeholder: String = "Name"
    
    // Appearance
    var height: CGFloat = 56
    var cornerRadius: CGFloat = 20
    var background: Color = Color(.sRGB, red: 0.14, green: 0.16, blue: 0.20, opacity: 1)   // #242831
    var textColor: Color = .white
    var placeholderColor: Color = .white.opacity(0.45)
    var focusedStroke: Color = .white.opacity(0.12)
    var unfocusedStroke: Color = .white.opacity(0.04)
    var font: Font = .system(size: 18, weight: .semibold, design: .rounded)
    var leadingIcon: Image? = nil
    var trailingIcon: Image? = nil   // you can use this for custom actions
    
    // Behavior
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .done
    var autocapitalization: TextInputAutocapitalization = .words
    var disableAutocorrection: Bool = false
    
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        ZStack {
            // Background + stroke
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(background)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(isFocused ? focusedStroke : unfocusedStroke, lineWidth: 1)
                )
                .frame(height: height)
            
            HStack(spacing: 12) {
                if let leadingIcon { leadingIcon.opacity(0.6) }
                
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(placeholderColor)
                            .font(font)
                            .padding(.vertical, 2)
                    }
                    
                    field
                        .font(font)
                        .foregroundColor(textColor)
                        .keyboardType(keyboard)
                        .submitLabel(submitLabel)
                        .textInputAutocapitalization(autocapitalization)
                        .disableAutocorrection(disableAutocorrection)
                        .focused($isFocused)
                }
                
                // Clear button
                if !text.isEmpty && !isSecure {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill").opacity(0.5)
                    }
                }
                
                // Trailing custom icon or eye toggle for secure
                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .opacity(0.6)
                    }
                } else if let trailingIcon {
                    trailingIcon.opacity(0.6)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: height)
        }
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture { isFocused = true }
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
    
    @ViewBuilder
    private var field: some View {
        if isSecure && !isPasswordVisible {
            SecureField("", text: $text)
        } else {
            TextField("", text: $text)
        }
    }
}

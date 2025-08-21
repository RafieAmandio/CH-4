import SwiftUI

struct SearchDropdown: View {
    // MARK: - Inputs
    @Binding var text: String
    var placeholder: String = "Profession"
    var options: [String] = []                           // for local filtering
    var searchProvider: ((String) async -> [String])? = nil // optional async search
    var onSelect: (String) -> Void = { _ in }

    // Appearance
    var height: CGFloat = 51
    var cornerRadius: CGFloat = 22
    var fieldBackground: Color = Color(red: 0.14, green: 0.16, blue: 0.20) // #242831
    var dropdownBackground: Color = Color(red: 0.12, green: 0.13, blue: 0.16)
    var textColor: Color = .white
    var placeholderColor: Color = .white.opacity(0.45)
    var focusedStroke: Color = .white.opacity(0.12)
    var unfocusedStroke: Color = .white.opacity(0.04)
    var font: Font = .system(size: 18, weight: .semibold, design: .rounded)
    var maxVisibleRows: Int = 6

    // MARK: - State
    @FocusState private var focused: Bool
    @State private var results: [String] = []
    @State private var isLoading = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Field
            field
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fieldBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(focused ? focusedStroke : unfocusedStroke, lineWidth: 1)
                        )
                )
                .overlay(alignment: .trailing) {
                    HStack(spacing: 8) {
                        if !text.isEmpty {
                            Button {
                                text = ""
                                results = []
                            } label: {
                                Image(systemName: "xmark.circle.fill").opacity(0.5)
                            }
                        }
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(focused ? 180 : 0))
                            .opacity(0.6)
                            .animation(.easeInOut(duration: 0.15), value: focused)
                    }
                    .padding(.trailing, 14)
                }

            // Dropdown
            if focused && (!results.isEmpty || isLoading) {
                dropdown
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(1)
                    .offset(y: height + 6)
            }
        }
        .onChange(of: text) { _ in
            Task { await runSearch() }
        }
        .onChange(of: focused) { new in
            if new { Task { await runSearch() } }
        }
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }

    // MARK: - Subviews
    private var field: some View {
        HStack(spacing: 12) {
            Image(systemName: "briefcase.fill").opacity(0.6)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(placeholderColor)
                        .font(font).padding(.vertical, 2)
                }
                TextField("", text: $text)
                    .font(font)
                    .foregroundColor(textColor)
                    .focused($focused)
                    .submitLabel(.search)
            }
        }
        .padding(.horizontal, 18)
        .frame(height: height)
    }

    private var dropdown: some View {
        VStack(spacing: 0) {
            if isLoading {
                HStack {
                    ProgressView().scaleEffect(0.9)
                    Text("Searching…").foregroundColor(.white.opacity(0.7))
                        .font(.callout)
                    Spacer()
                }
                .padding(12)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(results, id: \.self) { item in
                            Button {
                                select(item)
                            } label: {
                                HStack {
                                    Text(item)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color.white.opacity(0.04))
                                    .opacity(0)
                                    .contentShape(Rectangle())
                            )
                        }
                    }
                }
                .frame(maxHeight: rowHeight() * CGFloat(maxVisibleRows))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(dropdownBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(radius: 18, y: 8)
        )
        .padding(.trailing, 0)
        .padding(.leading, 0)
    }

    // MARK: - Logic
    private func runSearch() async {
        guard focused else { return }
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if let searchProvider {
            isLoading = true
            let out = await searchProvider(q)
            results = out
            isLoading = false
        } else {
            let data = options
            if q.isEmpty {
                results = data.prefix(20).map { $0 }
            } else {
                results = data.filter { $0.localizedCaseInsensitiveContains(q) }
            }
        }
    }

    private func select(_ value: String) {
        text = value
        focused = false
        results = []
        onSelect(value)
        // dismiss keyboard
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    private func rowHeight() -> CGFloat { 44 }
}

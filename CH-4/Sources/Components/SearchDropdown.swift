import SwiftUI

@MainActor
struct SearchDropdown: View {
    // MARK: - Inputs
    @Binding var text: String
    var placeholder: String = "Profession"
    var options: [String] = []                                 // local list
    var searchProvider: ((String) async -> [String])? = nil    // async source
    var onSelect: (String) -> Void = { _ in }
    
    // MARK: - Appearance
    var height: CGFloat = 56
    var cornerRadius: CGFloat = 22
    var fieldBackground: Color = Color(red: 0.14, green: 0.16, blue: 0.20) // #242831
    var dropdownBackground: Color = Color(red: 0.12, green: 0.13, blue: 0.16)
    var textColor: Color = .white
    var placeholderColor: Color = .white.opacity(0.45)
    var focusedStroke: Color = .white.opacity(0.12)
    var unfocusedStroke: Color = .white.opacity(0.04)
    var font: Font = .system(size: 18, weight: .semibold, design: .rounded)
    var maxVisibleRows: Int = 6
    var debounceMs: UInt64 = 180_000_000 // 180ms
    
    // MARK: - State
    @FocusState private var focused: Bool
    @State private var isOpen = false
    @State private var results: [String] = []
    @State private var isLoading = false
    @State private var searchTask: Task<Void, Never>? = nil
    
    var body: some View {
        // Host view
        VStack(spacing: 0) {
            field
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fieldBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(isOpen ? focusedStroke : unfocusedStroke, lineWidth: 1)
                        )
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleOpen(true)
                    runSearchDebounced()
                }
        }
        // Render dropdown ABOVE siblings, anchored to the field
        .overlay(alignment: .topLeading) {
            if isOpen && (!results.isEmpty || isLoading) {
                dropdown
                    .offset(y: height + 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(1000)
                    .allowsHitTesting(true)
            }
        }
        .zIndex(isOpen ? 1000 : 0)
        .onChange(of: focused) { new in
            if new { toggleOpen(true); runSearchDebounced() }
        }
        .onChange(of: text) { _ in
            // keep text editable + reactive
            if isOpen { runSearchDebounced() }
        }
    }
    
    // MARK: - Subviews
    private var field: some View {
        HStack(spacing: 12) {
            Image(systemName: "briefcase.fill").opacity(0.6)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(placeholderColor)
                        .font(font)
                        .padding(.vertical, 2)
                }
                
                TextField("", text: $text)
                    .font(font)
                    .foregroundColor(textColor)
                    .focused($focused)
                    .submitLabel(.search)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            
            if !text.isEmpty {
                Button {
                    text = ""
                    results = []
                } label: {
                    Image(systemName: "xmark.circle.fill").opacity(0.5)
                }
                .accessibilityLabel("Clear text")
            }
            
            Button {
                toggleOpen(!isOpen)
                if isOpen { runSearchDebounced() }
            } label: {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isOpen ? 180 : 0))
                    .opacity(0.6)
                    .animation(.easeInOut(duration: 0.15), value: isOpen)
            }
            .accessibilityLabel(isOpen ? "Hide options" : "Show options")
        }
        .padding(.horizontal, 18)
        .frame(height: height)
    }
    
    private var dropdown: some View {
        VStack(spacing: 0) {
            if isLoading {
                HStack(spacing: 10) {
                    ProgressView().scaleEffect(0.9)
                    Text("Searching…")
                        .foregroundColor(.white.opacity(0.7))
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
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }
                            .contentShape(Rectangle())
                            
                            // thin divider
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 0.5)
                                .padding(.leading, 14)
                        }
                    }
                }
                .frame(height: 200)
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
        // Swallow taps so the field behind doesn’t receive them
        .onTapGesture { }
    }
    
    // MARK: - Logic
    private func toggleOpen(_ open: Bool) {
        withAnimation(.easeInOut(duration: 0.15)) {
            isOpen = open
        }
        if open { focused = true }
    }
    
    private var rowHeight: CGFloat { 50 }
    
    private func runSearchDebounced() {
        searchTask?.cancel()
        searchTask = Task {
            // debounce
            try? await Task.sleep(nanoseconds: debounceMs)
            await runSearch()
        }
    }
    
    private func runSearch() async {
        guard isOpen else { return }
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let searchProvider {
            isLoading = true
            let out = await searchProvider(q)
            // If task was cancelled mid-flight, don’t apply
            if Task.isCancelled { return }
            results = out
            isLoading = false
        } else {
            let data = options
            if q.isEmpty {
                results = Array(data.prefix(20))
            } else {
                results = data.filter { $0.localizedCaseInsensitiveContains(q) }
            }
        }
    }
    
    private func select(_ value: String) {
        text = value
        onSelect(value)
        results = []
        toggleOpen(false)
        
        // Dismiss keyboard
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
}

// MARK: - Convenience initializers (avoid trailing-closure ambiguity)
extension SearchDropdown {
    init(
        text: Binding<String>,
        placeholder: String = "Profession",
        options: [String],
        onSelect: @escaping (String) -> Void
    ) {
        self.init(text: text,
                  placeholder: placeholder,
                  options: options,
                  searchProvider: nil,
                  onSelect: onSelect)
    }
    
    init(
        text: Binding<String>,
        placeholder: String = "Profession",
        searchProvider: @escaping (String) async -> [String],
        onSelect: @escaping (String) -> Void
    ) {
        self.init(text: text,
                  placeholder: placeholder,
                  options: [],
                  searchProvider: searchProvider,
                  onSelect: onSelect)
    }
}

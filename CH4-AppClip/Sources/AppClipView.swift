import SwiftUI

struct AppClipView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("CH-4 App Clip")
                .font(.title)
            Text("This is the App Clip version of CH-4")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    AppClipView()
} 
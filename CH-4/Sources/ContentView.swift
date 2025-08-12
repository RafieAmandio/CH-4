import SwiftUI

struct ContentView: View {
    @Namespace private var animation
    @State private var path: [String] = []

    var body: some View {
        SignInView()
    }
}

private struct MiniPlayerCard: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay(Image(systemName: "music.note").font(.title2))

            VStack(alignment: .leading, spacing: 2) {
                Text("Lo-Fi Beats").font(.headline)
                Text("Artist Name").foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "play.fill")
                .font(.title3)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2, y: 1)
    }
}

private struct PlayerDetail: View {
    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 24)
                .fill(.gray.opacity(0.15))
                .frame(height: 260)
                .overlay(Image(systemName: "music.quarternote.3").font(.largeTitle))

            Text("Lo-Fi Beats")
                .font(.largeTitle.weight(.semibold))

            Text("Artist Name • Album")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Now Playing")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
}


#Preview {
    ContentView()
}

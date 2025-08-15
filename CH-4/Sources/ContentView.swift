import SwiftUI
import UIComponentsKit
import UIKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Debug section to show available fonts
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug: Available Fonts")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Button("Register Custom Fonts") {
//                        AppFont.ensureFontsRegistered()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 8)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(UIFont.familyNames.sorted(), id: \.self) { family in
                                Text("Family: \(family)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(UIFont.fontNames(forFamilyName: family), id: \.self) { fontName in
                                    Text("  - \(fontName)")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Divider()
                
                // Test custom fonts
                VStack(spacing: 16) {
                    Text("Custom Font Test")
                        .font(AppFont.bodyMedium)
                    
                    Text("Urbanist-SemiBold (28pt)")
                        .font(AppFont.headingLarge)
                        .foregroundColor(.primary)
                    
                    Text("Urbanist-SemiBold (22pt)")
                        .font(AppFont.headingMedium)
                        .foregroundColor(.primary)
                    
                    Text("Urbanist-Regular (16pt)")
                        .font(AppFont.bodyMedium)
                        .foregroundColor(.primary)
                    
                    Text("Urbanist-Regular (14pt)")
                        .font(AppFont.bodySmall)
                        .foregroundColor(.primary)
                    
                    // Check if Urbanist fonts are available
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Font Availability Check:")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("Urbanist-SemiBold: \(UIFont.familyNames.contains("Urbanist") ? "✅ Available" : "❌ Not Available")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Urbanist-Regular: \(UIFont.familyNames.contains("Urbanist") ? "✅ Available" : "❌ Not Available")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                NavigationLink(destination: SignInView()) {
                    Text("Go to Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("CH-4")
        }
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

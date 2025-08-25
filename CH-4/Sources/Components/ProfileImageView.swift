//
//  ProfileImageView.swift
//  CH-4
//
//  Created by Dwiki on 25/08/25.
//

import SwiftUI

struct ProfileImageView: View {
    let imageURL: String?
    @State private var isImageLoaded = false
    
    var body: some View {
        Group {
            if let urlString = imageURL,
               let url = URL(string: urlString),
               isImageLoaded {
                // Only load AsyncImage after view is stable
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.7)
                            )
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                    case .failure:
                        fallbackImage
                        
                    @unknown default:
                        fallbackImage
                    }
                }
                // Add timeout to prevent infinite loading
                .task {
                    try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                    // Force fallback if still loading
                }
            } else {
                // Show fallback immediately
                fallbackImage
            }
        }
        .onAppear {
            // Delay loading to avoid blocking initial render
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isImageLoaded = true
            }
        }
    }
    
    private var fallbackImage: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            )
    }
}


struct CachedProfileImage: View {
    let imageURL: String?
    @StateObject private var cacheManager = ImageCacheManager.shared
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Group {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                        }
                    )
            }
        }
        .onAppear {
            loadImageIfNeeded()
        }
        .onChange(of: imageURL) { _ in
            loadImageIfNeeded()
        }
    }
    
    private func loadImageIfNeeded() {
        guard let imageURL = imageURL,
              !imageURL.isEmpty,
              loadedImage == nil,
              !isLoading else { return }
        
        isLoading = true
        
        Task {
            // Add small delay to prevent blocking initial render
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            let image = await cacheManager.loadImage(from: imageURL)
            
            await MainActor.run {
                self.loadedImage = image
                self.isLoading = false
            }
        }
    }
}

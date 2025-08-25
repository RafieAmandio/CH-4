//
//  ImageCacheManager.swift
//  CH-4
//
//  Created by Dwiki on 25/08/25.
//

import Foundation
import SwiftUI

@MainActor
class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private var cache: [String: UIImage] = [:]
    private var loadingTasks: [String: Task<UIImage?, Never>] = [:]
    
    private init() {}
    
    func loadImage(from urlString: String) async -> UIImage? {
        // Return cached image if available
        if let cachedImage = cache[urlString] {
            return cachedImage
        }
        
        // Check if already loading
        if let existingTask = loadingTasks[urlString] {
            return await existingTask.value
        }
        
        // Create new loading task
        let task = Task<UIImage?, Never> {
            guard let url = URL(string: urlString) else { return nil }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let image = UIImage(data: data)
                
                // Cache the result
                await MainActor.run {
                    if let image = image {
                        cache[urlString] = image
                    }
                    loadingTasks.removeValue(forKey: urlString)
                }
                
                return image
            } catch {
                await MainActor.run {
                    loadingTasks.removeValue(forKey: urlString)
                }
                return nil
            }
        }
        
        loadingTasks[urlString] = task
        return await task.value
    }
}

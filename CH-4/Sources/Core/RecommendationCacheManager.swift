
import Foundation

public class RecommendationCacheManager {
    static let shared = RecommendationCacheManager()
    
    private enum CacheKeys {
        static let recommendations = "cached_recommendations"
        static let lastFetchDate = "recommendations_last_fetch"
        static let eventId = "recommendations_event_id"
    }
    
    // Cache expiration time (30 minutes)
    private let cacheExpirationInterval: TimeInterval = 30 * 60
    
    private init() {}
    
    // MARK: - Cache Operations
    func cacheRecommendations(_ recommendations: [RecommendationModel], for eventId: String) {
        do {
            let data = try JSONEncoder().encode(recommendations)
            UserDefaults.standard.set(data, forKey: CacheKeys.recommendations)
            UserDefaults.standard.set(Date(), forKey: CacheKeys.lastFetchDate)
            UserDefaults.standard.set(eventId, forKey: CacheKeys.eventId)
        } catch {
            print("Failed to cache recommendations: \(error)")
        }
    }
    
    func getCachedRecommendations(for eventId: String) -> [RecommendationModel]? {
        // Check if cache is for the same event
        guard let cachedEventId = UserDefaults.standard.string(forKey: CacheKeys.eventId),
              cachedEventId == eventId else {
            return nil
        }
        
        // Check if cache is still valid
        guard isCacheValid() else {
            clearCache()
            return nil
        }
        
        // Return cached data
        guard let data = UserDefaults.standard.data(forKey: CacheKeys.recommendations) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode([RecommendationModel].self, from: data)
        } catch {
            print("Failed to decode cached recommendations: \(error)")
            clearCache()
            return nil
        }
    }
    
    func isCacheValid() -> Bool {
        guard let lastFetch = UserDefaults.standard.object(forKey: CacheKeys.lastFetchDate) as? Date else {
            return false
        }
        
        return Date().timeIntervalSince(lastFetch) < cacheExpirationInterval
    }
    
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: CacheKeys.recommendations)
        UserDefaults.standard.removeObject(forKey: CacheKeys.lastFetchDate)
        UserDefaults.standard.removeObject(forKey: CacheKeys.eventId)
    }
    
    func getCacheAge() -> TimeInterval? {
        guard let lastFetch = UserDefaults.standard.object(forKey: CacheKeys.lastFetchDate) as? Date else {
            return nil
        }
        return Date().timeIntervalSince(lastFetch)
    }
}

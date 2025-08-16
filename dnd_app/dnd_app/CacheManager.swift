import Foundation
import SwiftUI

// Forward declarations for types used in caching
// These are needed to satisfy the compiler when CacheManager is compiled separately

// MARK: - Cache Manager
final class CacheManager: ObservableObject {
    static let shared = CacheManager()
    
    // MARK: - Cache Types
    private var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // Максимум 100 изображений
        return cache
    }()
    
    private var dataCache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.countLimit = 200 // Максимум 200 объектов данных
        return cache
    }()
    
    private var objectCache: NSCache<NSString, AnyObject> = {
        let cache = NSCache<NSString, AnyObject>()
        cache.countLimit = 50 // Максимум 50 объектов
        return cache
    }()
    
    // MARK: - Cache Keys
    enum CacheKey: String {
        case spells = "spells_cache"
        case backgrounds = "backgrounds_cache"
        case feats = "feats_cache"
        case quotes = "quotes_cache"
        case relationships = "relationships_cache"
        case notes = "notes_cache"
        case characters = "characters_cache"
        case spellFilters = "spell_filters_cache"
        case featFilters = "feat_filters_cache"
        case themeSettings = "theme_settings_cache"
        case favorites = "favorites_cache"
    }
    
    // MARK: - Cache Statistics
    @Published var cacheStats = CacheStats()

    struct CacheStats {
        var imageCacheCount: Int = 0
        var dataCacheCount: Int = 0
        var objectCacheCount: Int = 0
        var imageMemoryUsage: Int64 = 0
        var dataMemoryUsage: Int64 = 0
        var objectMemoryUsage: Int64 = 0
        var totalMemoryUsage: Int64 = 0
        var cacheHits: Int = 0
        var cacheMisses: Int = 0
    }

    // Separate counters to track cache usage
    private var imageCacheItemCount: Int = 0
    private var dataCacheItemCount: Int = 0
    private var objectCacheItemCount: Int = 0

    // Track memory usage manually using cost dictionaries
    private var imageCacheCosts: [String: Int] = [:]
    private var dataCacheCosts: [String: Int] = [:]
    private var objectCacheCosts: [String: Int] = [:]
    private var imageCacheTotalCost: Int = 0
    private var dataCacheTotalCost: Int = 0
    private var objectCacheTotalCost: Int = 0
    
    private init() {
        setupCacheNotifications()
        updateStats()
    }
    
    // MARK: - Image Caching
    func cacheImage(_ image: UIImage, for key: String) {
        let nsKey = NSString(string: key)
        let cost = image.pngData()?.count ?? 0
        if let existing = imageCacheCosts[key] {
            imageCacheTotalCost -= existing
        } else {
            imageCacheItemCount += 1
        }
        imageCacheCosts[key] = cost
        imageCacheTotalCost += cost
        imageCache.setObject(image, forKey: nsKey, cost: cost)
        updateStats()
    }
    
    func getImage(for key: String) -> UIImage? {
        let nsKey = NSString(string: key)
        if let image = imageCache.object(forKey: nsKey) {
            cacheStats.cacheHits += 1
            return image
        }
        cacheStats.cacheMisses += 1
        return nil
    }
    
    // MARK: - Data Caching
    func cacheData(_ data: Data, for key: String) {
        let nsKey = NSString(string: key)
        let nsData = NSData(data: data)
        let cost = data.count
        if let existing = dataCacheCosts[key] {
            dataCacheTotalCost -= existing
        } else {
            dataCacheItemCount += 1
        }
        dataCacheCosts[key] = cost
        dataCacheTotalCost += cost
        dataCache.setObject(nsData, forKey: nsKey, cost: cost)
        updateStats()
    }
    
    func getData(for key: String) -> Data? {
        let nsKey = NSString(string: key)
        if let nsData = dataCache.object(forKey: nsKey) {
            cacheStats.cacheHits += 1
            return Data(referencing: nsData)
        }
        cacheStats.cacheMisses += 1
        return nil
    }
    
    // MARK: - Object Caching
    func cacheObject<T: AnyObject>(_ object: T, for key: String) {
        let nsKey = NSString(string: key)
        if objectCache.object(forKey: nsKey) == nil {
            objectCacheItemCount += 1
            objectCacheCosts[key] = 0
        }
        objectCache.setObject(object, forKey: nsKey)
        updateStats()
    }
    
    func getObject<T: AnyObject>(for key: String) -> T? {
        let nsKey = NSString(string: key)
        if let object = objectCache.object(forKey: nsKey) as? T {
            cacheStats.cacheHits += 1
            return object
        }
        cacheStats.cacheMisses += 1
        return nil
    }
    
    // MARK: - Codable Object Caching
    func cacheCodable<T: Codable>(_ object: T, for key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            cacheData(data, for: key)
        } catch {
            print("❌ [CACHE] Failed to encode object for key \(key): \(error)")
        }
    }
    
    func getCodable<T: Codable>(for key: String) -> T? {
        guard let data = getData(for: key) else { return nil }
        
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print("❌ [CACHE] Failed to decode object for key \(key): \(error)")
            return nil
        }
    }
    
    // MARK: - Cache Management
    func clearAllCaches() {
        imageCache.removeAllObjects()
        dataCache.removeAllObjects()
        objectCache.removeAllObjects()
        imageCacheItemCount = 0
        dataCacheItemCount = 0
        objectCacheItemCount = 0
        imageCacheTotalCost = 0
        dataCacheTotalCost = 0
        objectCacheTotalCost = 0
        imageCacheCosts.removeAll()
        dataCacheCosts.removeAll()
        objectCacheCosts.removeAll()
        updateStats()
        print("✅ [CACHE] All caches cleared")
    }
    
    func clearCache(for key: String) {
        let nsKey = NSString(string: key)
        if let cost = imageCacheCosts.removeValue(forKey: key) {
            imageCacheItemCount -= 1
            imageCacheTotalCost -= cost
            imageCache.removeObject(forKey: nsKey)
        }
        if let cost = dataCacheCosts.removeValue(forKey: key) {
            dataCacheItemCount -= 1
            dataCacheTotalCost -= cost
            dataCache.removeObject(forKey: nsKey)
        }
        if let cost = objectCacheCosts.removeValue(forKey: key) {
            objectCacheItemCount -= 1
            objectCacheTotalCost -= cost
            objectCache.removeObject(forKey: nsKey)
        }
        updateStats()
    }
    
    func clearImageCache() {
        imageCache.removeAllObjects()
        imageCacheItemCount = 0
        imageCacheTotalCost = 0
        imageCacheCosts.removeAll()
        updateStats()
        print("✅ [CACHE] Image cache cleared")
    }
    
    func clearDataCache() {
        dataCache.removeAllObjects()
        dataCacheItemCount = 0
        dataCacheTotalCost = 0
        dataCacheCosts.removeAll()
        updateStats()
        print("✅ [CACHE] Data cache cleared")
    }
    
    func clearObjectCache() {
        objectCache.removeAllObjects()
        objectCacheItemCount = 0
        objectCacheTotalCost = 0
        objectCacheCosts.removeAll()
        updateStats()
        print("✅ [CACHE] Object cache cleared")
    }
    
    // MARK: - Cache Statistics
    private func updateStats() {
        cacheStats.imageCacheCount = imageCacheItemCount
        cacheStats.dataCacheCount = dataCacheItemCount
        cacheStats.objectCacheCount = objectCacheItemCount

        // Примерный расчет использования памяти
        cacheStats.imageMemoryUsage = Int64(imageCacheTotalCost)
        cacheStats.dataMemoryUsage = Int64(dataCacheTotalCost)
        cacheStats.objectMemoryUsage = Int64(objectCacheTotalCost)
        cacheStats.totalMemoryUsage = cacheStats.imageMemoryUsage + cacheStats.dataMemoryUsage + cacheStats.objectMemoryUsage
    }
    
    // MARK: - Cache Notifications
    private func setupCacheNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }
    
    private func handleMemoryWarning() {
        print("⚠️ [CACHE] Memory warning received, clearing caches")
        clearAllCaches()
    }
    
    // MARK: - Cache Performance
    func getCacheHitRate() -> Double {
        let total = cacheStats.cacheHits + cacheStats.cacheMisses
        guard total > 0 else { return 0.0 }
        return Double(cacheStats.cacheHits) / Double(total)
    }
    
    func getCacheStats() -> String {
        let hitRate = getCacheHitRate()
        let imageSize = Double(cacheStats.imageMemoryUsage) / 1024 / 1024
        let dataSize = Double(cacheStats.dataMemoryUsage) / 1024 / 1024
        let objectSize = Double(cacheStats.objectMemoryUsage) / 1024 / 1024
        return """
        Cache Statistics:
        - Image Cache: \(cacheStats.imageCacheCount) items (\(String(format: "%.2f", imageSize)) MB)
        - Data Cache: \(cacheStats.dataCacheCount) items (\(String(format: "%.2f", dataSize)) MB)
        - Object Cache: \(cacheStats.objectCacheCount) items (\(String(format: "%.2f", objectSize)) MB)
        - Hit Rate: \(String(format: "%.1f", hitRate * 100))%
        - Total Hits: \(cacheStats.cacheHits)
        - Total Misses: \(cacheStats.cacheMisses)
        """
    }
}

// MARK: - Cacheable Protocol
protocol Cacheable {
    var cacheKey: String { get }
    var cacheExpiration: TimeInterval { get }
}

// MARK: - Cache Extensions
extension CacheManager {
    // MARK: - Spells Caching
    func cacheSpells(_ spells: [Spell]) {
        cacheCodable(spells, for: CacheKey.spells.rawValue)
        print("✅ [CACHE] Cached \(spells.count) spells")
    }
    
    func getCachedSpells() -> [Spell]? {
        return getCodable(for: CacheKey.spells.rawValue)
    }
    
    // MARK: - Backgrounds Caching
    func cacheBackgrounds(_ backgrounds: [Background]) {
        cacheCodable(backgrounds, for: CacheKey.backgrounds.rawValue)
        print("✅ [CACHE] Cached \(backgrounds.count) backgrounds")
    }
    
    func getCachedBackgrounds() -> [Background]? {
        return getCodable(for: CacheKey.backgrounds.rawValue)
    }
    
    // MARK: - Feats Caching
    func cacheFeats(_ feats: [Feat]) {
        cacheCodable(feats, for: CacheKey.feats.rawValue)
        print("✅ [CACHE] Cached \(feats.count) feats")
    }
    
    func getCachedFeats() -> [Feat]? {
        return getCodable(for: CacheKey.feats.rawValue)
    }
    
    // MARK: - Quotes Caching
    func cacheQuotes(_ quotes: [String: [Quote]]) {
        cacheCodable(quotes, for: CacheKey.quotes.rawValue)
        print("✅ [CACHE] Cached quotes for \(quotes.count) categories")
    }
    
    func getCachedQuotes() -> [String: [Quote]]? {
        return getCodable(for: CacheKey.quotes.rawValue)
    }
    
    // MARK: - Relationships Caching
    func cacheRelationships(_ relationships: [Person]) {
        cacheCodable(relationships, for: CacheKey.relationships.rawValue)
        print("✅ [CACHE] Cached \(relationships.count) relationships")
    }
    
    func getCachedRelationships() -> [Person]? {
        return getCodable(for: CacheKey.relationships.rawValue)
    }
    
    // MARK: - Notes Caching
    func cacheNotes(_ notes: [Note]) {
        cacheCodable(notes, for: CacheKey.notes.rawValue)
        print("✅ [CACHE] Cached \(notes.count) notes")
    }
    
    func getCachedNotes() -> [Note]? {
        return getCodable(for: CacheKey.notes.rawValue)
    }
    
    // MARK: - Characters Caching
    func cacheCharacters(_ characters: [Character]) {
        cacheCodable(characters, for: CacheKey.characters.rawValue)
        print("✅ [CACHE] Cached \(characters.count) characters")
    }
    
    func getCachedCharacters() -> [Character]? {
        return getCodable(for: CacheKey.characters.rawValue)
    }
    
    // MARK: - Filters Caching
    func cacheSpellFilters(_ filters: SpellFilters) {
        cacheCodable(filters, for: CacheKey.spellFilters.rawValue)
    }
    
    func getCachedSpellFilters() -> SpellFilters? {
        return getCodable(for: CacheKey.spellFilters.rawValue)
    }
    
    func cacheFeatFilters(_ filters: FeatFilters) {
        cacheCodable(filters, for: CacheKey.featFilters.rawValue)
    }
    
    func getCachedFeatFilters() -> FeatFilters? {
        return getCodable(for: CacheKey.featFilters.rawValue)
    }
    
    // MARK: - Theme Settings Caching
    func cacheThemeSettings(_ settings: ThemeSettings) {
        cacheCodable(settings, for: CacheKey.themeSettings.rawValue)
    }
    
    func getCachedThemeSettings() -> ThemeSettings? {
        return getCodable(for: CacheKey.themeSettings.rawValue)
    }
    
    // MARK: - Favorites Caching
    func cacheFavorites(_ favorites: [String]) {
        cacheCodable(favorites, for: CacheKey.favorites.rawValue)
    }
    
    func getCachedFavorites() -> [String]? {
        return getCodable(for: CacheKey.favorites.rawValue)
    }
}

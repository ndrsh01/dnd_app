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
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        return cache
    }()
    
    private var dataCache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.countLimit = 200 // Максимум 200 объектов данных
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
        return cache
    }()
    
    private var objectCache: NSCache<NSString, AnyObject> = {
        let cache = NSCache<NSString, AnyObject>()
        cache.countLimit = 50 // Максимум 50 объектов
        return cache
    }()

    // MARK: - Expiration Tracking
    /// Maps cache keys to their expiration date. Keys without an entry never expire.
    private var expirationDates: [String: Date] = [:]
    
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
        var totalMemoryUsage: Int64 = 0
        var cacheHits: Int = 0
        var cacheMisses: Int = 0
    }
    
    private init() {
        setupCacheNotifications()
        updateStats()
    }

    // MARK: - Expiration Helpers
    private func setExpiration(for key: String, duration: TimeInterval) {
        if duration > 0 {
            expirationDates[key] = Date().addingTimeInterval(duration)
        } else {
            expirationDates.removeValue(forKey: key)
        }
    }

    private func isExpired(_ key: String) -> Bool {
        if let expiry = expirationDates[key], Date() >= expiry {
            clearCache(for: key)
            return true
        }
        return false
    }
    
    // MARK: - Image Caching
    func cacheImage(_ image: UIImage, for key: String, expiration: TimeInterval = 0) {
        let nsKey = NSString(string: key)
        imageCache.setObject(image, forKey: nsKey)
        setExpiration(for: key, duration: expiration)
        updateStats()
    }

    func getImage(for key: String) -> UIImage? {
        guard !isExpired(key) else {
            cacheStats.cacheMisses += 1
            return nil
        }

        let nsKey = NSString(string: key)
        if let image = imageCache.object(forKey: nsKey) {
            cacheStats.cacheHits += 1
            return image
        }
        cacheStats.cacheMisses += 1
        return nil
    }

    // MARK: - Data Caching
    func cacheData(_ data: Data, for key: String, expiration: TimeInterval = 0) {
        let nsKey = NSString(string: key)
        let nsData = NSData(data: data)
        dataCache.setObject(nsData, forKey: nsKey)
        setExpiration(for: key, duration: expiration)
        updateStats()
    }

    func getData(for key: String) -> Data? {
        guard !isExpired(key) else {
            cacheStats.cacheMisses += 1
            return nil
        }

        let nsKey = NSString(string: key)
        if let nsData = dataCache.object(forKey: nsKey) {
            cacheStats.cacheHits += 1
            return Data(referencing: nsData)
        }
        cacheStats.cacheMisses += 1
        return nil
    }

    // MARK: - Object Caching
    func cacheObject<T: AnyObject>(_ object: T, for key: String, expiration: TimeInterval = 0) {
        let nsKey = NSString(string: key)
        objectCache.setObject(object, forKey: nsKey)
        setExpiration(for: key, duration: expiration)
        updateStats()
    }

    func getObject<T: AnyObject>(for key: String) -> T? {
        guard !isExpired(key) else {
            cacheStats.cacheMisses += 1
            return nil
        }

        let nsKey = NSString(string: key)
        if let object = objectCache.object(forKey: nsKey) as? T {
            cacheStats.cacheHits += 1
            return object
        }
        cacheStats.cacheMisses += 1
        return nil
    }

    // MARK: - Codable Object Caching
    func cacheCodable<T: Codable>(_ object: T, for key: String, expiration: TimeInterval = 0) {
        do {
            let data = try JSONEncoder().encode(object)
            cacheData(data, for: key, expiration: expiration)
        } catch {
            print("❌ [CACHE] Failed to encode object for key \(key): \(error)")
        }
    }

    func getCodable<T: Codable>(for key: String) -> T? {
        guard !isExpired(key) else {
            cacheStats.cacheMisses += 1
            return nil
        }

        let nsKey = NSString(string: key)
        if let nsData = dataCache.object(forKey: nsKey) {
            do {
                let object = try JSONDecoder().decode(T.self, from: Data(referencing: nsData))
                cacheStats.cacheHits += 1
                return object
            } catch {
                print("❌ [CACHE] Failed to decode object for key \(key): \(error)")
            }
        }
        cacheStats.cacheMisses += 1
        return nil
    }
    
    // MARK: - Cache Management
    func clearAllCaches() {
        imageCache.removeAllObjects()
        dataCache.removeAllObjects()
        objectCache.removeAllObjects()
        expirationDates.removeAll()
        updateStats()
        print("✅ [CACHE] All caches cleared")
    }

    func clearCache(for key: String) {
        let nsKey = NSString(string: key)
        imageCache.removeObject(forKey: nsKey)
        dataCache.removeObject(forKey: nsKey)
        objectCache.removeObject(forKey: nsKey)
        expirationDates.removeValue(forKey: key)
        updateStats()
    }
    
    func clearImageCache() {
        imageCache.removeAllObjects()
        expirationDates.removeAll()
        updateStats()
        print("✅ [CACHE] Image cache cleared")
    }
    
    func clearDataCache() {
        dataCache.removeAllObjects()
        expirationDates.removeAll()
        updateStats()
        print("✅ [CACHE] Data cache cleared")
    }
    
    func clearObjectCache() {
        objectCache.removeAllObjects()
        expirationDates.removeAll()
        updateStats()
        print("✅ [CACHE] Object cache cleared")
    }
    
    // MARK: - Cache Statistics
    private func updateStats() {
        cacheStats.imageCacheCount = imageCache.totalCostLimit > 0 ? imageCache.totalCostLimit : 0
        cacheStats.dataCacheCount = dataCache.totalCostLimit > 0 ? dataCache.totalCostLimit : 0
        cacheStats.objectCacheCount = objectCache.totalCostLimit > 0 ? objectCache.totalCostLimit : 0
        
        // Примерный расчет использования памяти
        let imageMemory = Int64(imageCache.totalCostLimit)
        let dataMemory = Int64(dataCache.totalCostLimit)
        let objectMemory = Int64(objectCache.totalCostLimit)
        cacheStats.totalMemoryUsage = imageMemory + dataMemory + objectMemory
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
        return """
        Cache Statistics:
        - Image Cache: \(imageCache.totalCostLimit / 1024 / 1024) MB
        - Data Cache: \(dataCache.totalCostLimit / 1024 / 1024) MB
        - Object Cache: \(objectCache.totalCostLimit / 1024 / 1024) MB
        - Hit Rate: \(String(format: "%.1f", hitRate * 100))%
        - Total Hits: \(cacheStats.cacheHits)
        - Total Misses: \(cacheStats.cacheMisses)
        """
    }
}

// MARK: - Cacheable Protocol
/// Types that conform to `Cacheable` can be stored in `CacheManager`
/// with an associated expiration time. Values with a nonzero
/// `cacheExpiration` are automatically invalidated once the interval
/// has passed.
protocol Cacheable {
    /// Key used to store the value in the cache.
    var cacheKey: String { get }
    /// Lifetime of the cached value in seconds. `0` means the value never expires.
    var cacheExpiration: TimeInterval { get }
}

// MARK: - Cache Extensions
extension CacheManager {
    // MARK: - Spells Caching
    func cacheSpells(_ spells: [Spell]) {
        let cacheKey = spells.first?.cacheKey ?? CacheKey.spells.rawValue
        let expiration = spells.first?.cacheExpiration ?? 0
        cacheCodable(spells, for: cacheKey, expiration: expiration)
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

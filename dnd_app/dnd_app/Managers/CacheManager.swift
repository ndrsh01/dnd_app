import Foundation
import SwiftUI
import OSLog

// Forward declarations for types used in caching
// These are needed to satisfy the compiler when CacheManager is compiled separately

// MARK: - Cache Manager
final class CacheManager: ObservableObject {
    static let shared = CacheManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "dnd_app", category: "CacheManager")
    
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

    // MARK: - Disk Cache
    private let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = urls.first!.appendingPathComponent("CacheManager", isDirectory: true)
        return dir
    }()

    // MARK: - Expiration Tracking
    /// Maps cache keys to their expiration date. Keys without an entry never expire.
    private var expirationDates: [String: Date] = [:]

    private struct CacheEntry<T: Codable>: Codable {
        let value: T
        let expiry: Date?
    }

    private struct CacheFileHeader: Codable {
        let expiry: Date?
    }
    
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
        case favoritesSpells = "favorites_spells"
        case favoritesFeats = "favorites_feats"
        case favoritesBackgrounds = "favorites_backgrounds"
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
        createCacheDirectory()
        cleanupExpiredFiles()
        updateStats()
    }

    private func createCacheDirectory() {
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func fileURL(for key: String) -> URL {
        let safeKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return cacheDirectory.appendingPathComponent(safeKey).appendingPathExtension("json")
    }

    private func cleanupExpiredFiles() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else { return }
        for url in files {
            guard let data = try? Data(contentsOf: url),
                  let header = try? JSONDecoder().decode(CacheFileHeader.self, from: data) else { continue }
            if let expiry = header.expiry, expiry < Date() {
                try? fm.removeItem(at: url)
            }
        }
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
        let nsData = data as NSData
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

    // MARK: - Generic Codable Caching
    func cache<T: Codable>(_ object: T, for key: String, ttl: TimeInterval = 0) {
        let expiry = ttl > 0 ? Date().addingTimeInterval(ttl) : nil
        let entry = CacheEntry(value: object, expiry: expiry)
        do {
            let data = try JSONEncoder().encode(entry)
            let nsKey = NSString(string: key)
            dataCache.setObject(data as NSData, forKey: nsKey)
            if let expiry = expiry {
                expirationDates[key] = expiry
            } else {
                expirationDates.removeValue(forKey: key)
            }
            try data.write(to: fileURL(for: key), options: .atomic)
            updateStats()
        } catch {
            logger.error("Failed to encode object for key \(key, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    func get<T: Codable>(for key: String) -> T? {
        let nsKey = NSString(string: key)
        if let nsData = dataCache.object(forKey: nsKey) {
            do {
                let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: Data(referencing: nsData))
                if let expiry = entry.expiry, expiry < Date() {
                    clearCache(for: key)
                    cacheStats.cacheMisses += 1
                    return nil
                }
                cacheStats.cacheHits += 1
                return entry.value
            } catch {
                logger.error("Failed to decode object for key \(key, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }

        let url = fileURL(for: key)
        if let data = try? Data(contentsOf: url) {
            do {
                let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
                if let expiry = entry.expiry, expiry < Date() {
                    try? FileManager.default.removeItem(at: url)
                    cacheStats.cacheMisses += 1
                    return nil
                }
                dataCache.setObject(data as NSData, forKey: nsKey)
                if let expiry = entry.expiry {
                    expirationDates[key] = expiry
                }
                cacheStats.cacheHits += 1
                return entry.value
            } catch {
                logger.error("Failed to decode object for key \(key, privacy: .public): \(error.localizedDescription, privacy: .public)")
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
        try? FileManager.default.removeItem(at: cacheDirectory)
        createCacheDirectory()
        updateStats()
        logger.debug("All caches cleared")
    }

    func clearCache(for key: String) {
        let nsKey = NSString(string: key)
        imageCache.removeObject(forKey: nsKey)
        dataCache.removeObject(forKey: nsKey)
        objectCache.removeObject(forKey: nsKey)
        expirationDates.removeValue(forKey: key)
        try? FileManager.default.removeItem(at: fileURL(for: key))
        updateStats()
    }
    
    func clearImageCache() {
        imageCache.removeAllObjects()
        expirationDates.removeAll()
        updateStats()
        logger.debug("Image cache cleared")
    }
    
    func clearDataCache() {
        dataCache.removeAllObjects()
        expirationDates.removeAll()
        try? FileManager.default.removeItem(at: cacheDirectory)
        createCacheDirectory()
        updateStats()
        logger.debug("Data cache cleared")
    }
    
    func clearObjectCache() {
        objectCache.removeAllObjects()
        expirationDates.removeAll()
        updateStats()
        logger.debug("Object cache cleared")
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
        logger.warning("Memory warning received, clearing caches")
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


// MARK: - Cache Extensions
extension CacheManager {
    // MARK: - Spells Caching
    func cacheSpells(_ spells: [Spell]) {
        let cacheKey = spells.first?.cacheKey ?? CacheKey.spells.rawValue
        let expiration = spells.first?.cacheExpiration ?? 0
        cache(spells, for: cacheKey, ttl: expiration)
        logger.debug("Cached \(spells.count) spells")
    }
    
    func getCachedSpells() -> [Spell]? {
        return get(for: CacheKey.spells.rawValue)
    }
    
    // MARK: - Backgrounds Caching
    func cacheBackgrounds(_ backgrounds: [Background]) {
        cache(backgrounds, for: CacheKey.backgrounds.rawValue)
        logger.debug("Cached \(backgrounds.count) backgrounds")
    }
    
    func getCachedBackgrounds() -> [Background]? {
        return get(for: CacheKey.backgrounds.rawValue)
    }
    
    // MARK: - Feats Caching
    func cacheFeats(_ feats: [Feat]) {
        cache(feats, for: CacheKey.feats.rawValue)
        logger.debug("Cached \(feats.count) feats")
    }
    
    func getCachedFeats() -> [Feat]? {
        return get(for: CacheKey.feats.rawValue)
    }
    
    // MARK: - Quotes Caching
    func cacheQuotes(_ quotes: [String: [Quote]]) {
        cache(quotes, for: CacheKey.quotes.rawValue)
        logger.debug("Cached quotes for \(quotes.count) categories")
    }
    
    func getCachedQuotes() -> [String: [Quote]]? {
        return get(for: CacheKey.quotes.rawValue)
    }
    
    // MARK: - Relationships Caching
    func cacheRelationships(_ relationships: [Person]) {
        cache(relationships, for: CacheKey.relationships.rawValue)
        logger.debug("Cached \(relationships.count) relationships")
    }
    
    func getCachedRelationships() -> [Person]? {
        return get(for: CacheKey.relationships.rawValue)
    }
    
    // MARK: - Notes Caching
    func cacheNotes(_ notes: [Note]) {
        cache(notes, for: CacheKey.notes.rawValue)
        logger.debug("Cached \(notes.count) notes")
    }
    
    func getCachedNotes() -> [Note]? {
        return get(for: CacheKey.notes.rawValue)
    }
    
    // MARK: - Characters Caching
    func cacheCharacters(_ characters: [Character]) {
        cache(characters, for: CacheKey.characters.rawValue)
        logger.debug("Cached \(characters.count) characters")
    }
    
    func getCachedCharacters() -> [Character]? {
        return get(for: CacheKey.characters.rawValue)
    }
    
    // MARK: - Filters Caching
    func cacheSpellFilters(_ filters: SpellFilters) {
        cache(filters, for: CacheKey.spellFilters.rawValue)
    }
    
    func getCachedSpellFilters() -> SpellFilters? {
        return get(for: CacheKey.spellFilters.rawValue)
    }
    
    func cacheFeatFilters(_ filters: FeatFilters) {
        cache(filters, for: CacheKey.featFilters.rawValue)
    }
    
    func getCachedFeatFilters() -> FeatFilters? {
        return get(for: CacheKey.featFilters.rawValue)
    }
    
    // MARK: - Theme Settings Caching
    func cacheThemeSettings(_ settings: ThemeSettings) {
        cache(settings, for: CacheKey.themeSettings.rawValue)
    }
    
    func getCachedThemeSettings() -> ThemeSettings? {
        return get(for: CacheKey.themeSettings.rawValue)
    }
    
    // MARK: - Favorites Caching
    func cacheFavorites(_ favorites: [String]) {
        cache(favorites, for: CacheKey.favorites.rawValue)
    }
    
    func getCachedFavorites() -> [String]? {
        return get(for: CacheKey.favorites.rawValue)
    }

    func cacheFavoriteSpells(_ favorites: [String]) {
        cache(favorites, for: CacheKey.favoritesSpells.rawValue)
    }

    func getCachedFavoriteSpells() -> [String]? {
        return get(for: CacheKey.favoritesSpells.rawValue)
    }

    func cacheFavoriteFeats(_ favorites: [String]) {
        cache(favorites, for: CacheKey.favoritesFeats.rawValue)
    }

    func getCachedFavoriteFeats() -> [String]? {
        return get(for: CacheKey.favoritesFeats.rawValue)
    }

    func cacheFavoriteBackgrounds(_ favorites: [String]) {
        cache(favorites, for: CacheKey.favoritesBackgrounds.rawValue)
    }

    func getCachedFavoriteBackgrounds() -> [String]? {
        return get(for: CacheKey.favoritesBackgrounds.rawValue)
    }
}

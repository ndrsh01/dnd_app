import Foundation
import AVFoundation

// MARK: - Data models

struct QuotesData: Codable {
    let categories: [String: [String]]
}

final class QuoteManager: ObservableObject {
    // Published
    @Published private(set) var quotes: [String: [String]] = [:]
    @Published var categories: [String] = []
    @Published var currentQuote: String = ""
    @Published var favorites: [String] = []
    @Published var customPrefixes: [String] = [
        "как сказал один чел",
        "как спизданул один идиот",
        "говорили старцы",
        "моя лапа чует"
    ]
    @Published var selectedPrefixIndex: Int = 0
    @Published var usePrefix: Bool = false

    // Persist keys
    private let favoritesKey = "tabaxiFavorites_v2"
    private let customQuotesKey = "tabaxiCustomQuotes_v1"
    private let prefixKey = "tabaxiPrefixList_v1"

    private var player: AVAudioPlayer?
    private var isInitialized = false
    
    // Lazy initialization for better performance
    private func ensureInitialized() {
        guard !isInitialized else { return }
        isInitialized = true
        loadBundledQuotes()
        loadFavorites()
        loadCustomPrefixes()
        mergeCustomQuotesFromStorage()
        rebuildCategories()
    }

    // Init
    init() {
        // Defer heavy loading to first access
    }

    // MARK: - Loading bundled quotes
    private func loadBundledQuotes() {
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let decoded = try JSONDecoder().decode(QuotesData.self, from: data)
                quotes = decoded.categories
            } catch {
                print("❌ decode quotes.json: \(error)")
            }
        } else {
            print("❌ quotes.json not found in bundle")
        }
    }

    // MARK: - Categories
    private func rebuildCategories() {
        categories = quotes.keys.sorted()
    }

    // MARK: - Random
    func randomQuote(in category: String?) {
        ensureInitialized()
        
        let pool: [String]
        if let category = category, let arr = quotes[category], !arr.isEmpty {
            pool = arr
        } else {
            pool = quotes.values.flatMap { $0 }
        }
        guard !pool.isEmpty else { return }
        var raw = pool.randomElement() ?? ""
        if usePrefix, customPrefixes.indices.contains(selectedPrefixIndex) {
            let prefix = customPrefixes[selectedPrefixIndex]
            raw = "\(prefix): \(raw)"
        }
        currentQuote = raw
        playSound()
    }

    // MARK: - Add / remove
    func addQuote(category: String, text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        if quotes[category] == nil { quotes[category] = [] }
        quotes[category]?.append(clean)
        persistCustomQuote(category: category, text: clean)
        rebuildCategories()
    }

    func removeQuote(category: String, at indexSet: IndexSet) {
        guard var arr = quotes[category] else { return }
        for i in indexSet {
            if i < arr.count {
                let removed = arr[i]
                // Также вычищаем из избранного
                favorites.removeAll(where: { $0 == removed })
            }
        }
        arr.remove(atOffsets: indexSet)
        quotes[category] = arr
        saveFavorites()
        // (кастомные можно перезаписать, но здесь оставим упрощённо)
    }

    // MARK: - Favorites
    func toggleFavorite(_ quote: String) {
        if let idx = favorites.firstIndex(of: quote) {
            favorites.remove(at: idx)
        } else {
            favorites.insert(quote, at: 0)
        }
        saveFavorites()
    }

    func isFavorite(_ quote: String) -> Bool {
        favorites.contains(quote)
    }

    func removeFavorite(quote: String) {
        favorites.removeAll(where: { $0 == quote })
        saveFavorites()
    }

    private func loadFavorites() {
        if let arr = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favorites = arr
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
    }

    // MARK: - Custom prefixes
    func addPrefix(_ prefix: String) {
        let p = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !p.isEmpty else { return }
        customPrefixes.append(p)
        saveCustomPrefixes()
    }

    private func loadCustomPrefixes() {
        if let arr = UserDefaults.standard.array(forKey: prefixKey) as? [String], !arr.isEmpty {
            customPrefixes = arr
        }
    }

    private func saveCustomPrefixes() {
        UserDefaults.standard.set(customPrefixes, forKey: prefixKey)
    }

    // MARK: - Sound
    private func playSound() {
        // Lazy load audio player once
        if player == nil {
            let possiblePaths = [
                Bundle.main.url(forResource: "kachow", withExtension: "wav"),
                Bundle.main.url(forResource: "kachow", withExtension: "wav", subdirectory: "Resources"),
                Bundle.main.url(forResource: "kachow", withExtension: "wav", subdirectory: nil)
            ]
            
            guard let url = possiblePaths.compactMap({ $0 }).first else { 
                print("❌ kachow.wav not found")
                return 
            }
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay() // Pre-load for faster playback
            } catch {
                print("❌ sound error: \(error)")
                return
            }
        }
        
        player?.stop()
        player?.currentTime = 0
        player?.play()
    }

    // MARK: - Custom quotes persistence
    private func mergeCustomQuotesFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: customQuotesKey),
              let saved = try? JSONDecoder().decode([String: [String]].self, from: data) else { return }
        // Мержим по категориям
        for (k, v) in saved {
            if quotes[k] != nil {
                quotes[k]?.append(contentsOf: v)
            } else {
                quotes[k] = v
            }
        }
    }

    private func persistCustomQuote(category: String, text: String) {
        var saved: [String: [String]] = [:]
        if let data = UserDefaults.standard.data(forKey: customQuotesKey),
           let dec = try? JSONDecoder().decode([String: [String]].self, from: data) {
            saved = dec
        }
        var arr = saved[category] ?? []
        arr.append(text)
        saved[category] = arr
        if let data = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(data, forKey: customQuotesKey)
        }
    }
}

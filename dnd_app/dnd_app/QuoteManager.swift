import Foundation


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

    // Persist keys
    private let favoritesKey = "tabaxiFavorites_v2"
    private let customQuotesKey = "tabaxiCustomQuotes_v1"
    
    private var isInitialized = false
    
    // Lazy initialization for better performance
    private func ensureInitialized() {
        guard !isInitialized else { return }
        isInitialized = true
        loadBundledQuotes()
        loadFavorites()

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
        let raw = pool.randomElement() ?? ""
        currentQuote = raw
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

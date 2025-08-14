import Foundation


// MARK: - Data models

struct Quote: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    let text: String
    let isCustom: Bool
    let category: String
    let dateCreated: Date
    
    init(text: String, isCustom: Bool = false, category: String, dateCreated: Date = Date()) {
        self.text = text
        self.isCustom = isCustom
        self.category = category
        self.dateCreated = dateCreated
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Quote, rhs: Quote) -> Bool {
        lhs.id == rhs.id
    }
}

struct Category: Codable, Identifiable, Equatable {
    var id = UUID()
    let name: String
    let isCustom: Bool
    let dateCreated: Date
    
    init(name: String, isCustom: Bool = false, dateCreated: Date = Date()) {
        self.name = name
        self.isCustom = isCustom
        self.dateCreated = dateCreated
    }
}

struct QuotesData: Codable {
    let categories: [String: [String]]
}

@MainActor
final class QuoteManager: ObservableObject {
    // Published
    @Published private(set) var quotes: [String: [Quote]] = [:]
    @Published var categories: [Category] = []
    @Published var currentQuote: String = ""
    @Published var favorites: [String] = []

    // Persist keys
    private let favoritesKey = "tabaxiFavorites_v2"
    private let customQuotesKey = "tabaxiCustomQuotes_v2"
    private let customCategoriesKey = "tabaxiCustomCategories_v1"
    
    private var isInitialized = false
    private let cacheManager = CacheManager.shared
    
    // Lazy initialization for better performance
    private func ensureInitialized() {
        guard !isInitialized else { return }
        isInitialized = true
        
        // Сначала пытаемся загрузить из кэша
        if loadFromCache() {
            print("✅ [QUOTES] Загружено из кэша")
            return
        }
        
        loadBundledQuotes()
        loadFavorites()
        mergeCustomQuotesFromStorage()
        rebuildCategories()
        
        // Кэшируем данные
        cacheManager.cacheQuotes(quotes)
        cacheManager.cacheFavorites(favorites)
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
                // Конвертируем старый формат в новый
                for (categoryName, quotesArray) in decoded.categories {
                    let quotes = quotesArray.map { Quote(text: $0, isCustom: false, category: categoryName) }
                    self.quotes[categoryName] = quotes
                    
                    // Добавляем системную категорию
                    let category = Category(name: categoryName, isCustom: false)
                    if !self.categories.contains(where: { $0.name == categoryName }) {
                        self.categories.append(category)
                    }
                }
            } catch {
                print("❌ decode quotes.json: \(error)")
            }
        } else {
            print("❌ quotes.json not found in bundle")
        }
    }

    // MARK: - Categories
    private func rebuildCategories() {
        // Сортируем категории: сначала системные, потом пользовательские
        categories.sort { first, second in
            if first.isCustom != second.isCustom {
                return !first.isCustom // Системные сначала
            }
            return first.name < second.name
        }
    }

    // MARK: - Random
    func randomQuote(in category: String?) {
        ensureInitialized()
        
        let pool: [Quote]
        if let category = category, let arr = quotes[category], !arr.isEmpty {
            pool = arr
        } else {
            pool = quotes.values.flatMap { $0 }
        }
        guard !pool.isEmpty else { return }
        let quote = pool.randomElement() ?? Quote(text: "", isCustom: false, category: "")
        currentQuote = quote.text
    }

    // MARK: - Add / remove
    func addQuote(category: String, text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        
        // Создаем или получаем категорию
        if !categories.contains(where: { $0.name == category }) {
            let newCategory = Category(name: category, isCustom: true)
            categories.append(newCategory)
            saveCustomCategories()
        }
        
        if quotes[category] == nil { quotes[category] = [] }
        let newQuote = Quote(text: clean, isCustom: true, category: category)
        quotes[category]?.append(newQuote)
        persistCustomQuotes()
        rebuildCategories()
    }

    func removeQuote(category: String, at indexSet: IndexSet) {
        guard var arr = quotes[category] else { return }
        for i in indexSet {
            if i < arr.count {
                let removed = arr[i]
                // Также вычищаем из избранного
                favorites.removeAll(where: { $0 == removed.text })
            }
        }
        arr.remove(atOffsets: indexSet)
        quotes[category] = arr
        saveFavorites()
        
        // Если это пользовательская категория и она пуста, удаляем её
        if arr.isEmpty, let categoryObj = categories.first(where: { $0.name == category }), categoryObj.isCustom {
            categories.removeAll(where: { $0.name == category })
            quotes.removeValue(forKey: category)
            saveCustomCategories()
        }
        
        persistCustomQuotes()
    }
    
    func editQuote(oldQuote: String, newQuote: String) {
        for (category, quotesArray) in quotes {
            if let index = quotesArray.firstIndex(where: { $0.text == oldQuote }) {
                let updatedQuote = Quote(text: newQuote.trimmingCharacters(in: .whitespacesAndNewlines), 
                                       isCustom: quotesArray[index].isCustom, 
                                       category: category,
                                       dateCreated: quotesArray[index].dateCreated)
                quotes[category]?[index] = updatedQuote
                
                // Обновить в избранном тоже
                if let favIndex = favorites.firstIndex(of: oldQuote) {
                    favorites[favIndex] = newQuote.trimmingCharacters(in: .whitespacesAndNewlines)
                    saveFavorites()
                }
                
                if updatedQuote.isCustom {
                    persistCustomQuotes()
                }
                break
            }
        }
    }
    
    func removeQuoteByText(_ quote: String) {
        for (category, quotesArray) in quotes {
            if let index = quotesArray.firstIndex(where: { $0.text == quote }) {
                let removedQuote = quotesArray[index]
                quotes[category]?.remove(at: index)
                // Удалить из избранного тоже
                removeFavorite(quote: quote)
                
                // Если это пользовательская категория и она пуста, удаляем её
                if quotes[category]?.isEmpty == true, 
                   let categoryObj = categories.first(where: { $0.name == category }), 
                   categoryObj.isCustom {
                    categories.removeAll(where: { $0.name == category })
                    quotes.removeValue(forKey: category)
                    saveCustomCategories()
                }
                
                if removedQuote.isCustom {
                    persistCustomQuotes()
                }
                break
            }
        }
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





    // MARK: - Category management
    func addCategory(name: String) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        if !categories.contains(where: { $0.name == cleanName }) {
            let newCategory = Category(name: cleanName, isCustom: true)
            categories.append(newCategory)
            quotes[cleanName] = []
            saveCustomCategories()
            rebuildCategories()
        }
    }
    
    func removeCategory(_ category: Category) {
        guard category.isCustom else { return } // Нельзя удалять системные категории
        
        // Удаляем все цитаты из этой категории из избранного
        if let categoryQuotes = quotes[category.name] {
            for quote in categoryQuotes {
                favorites.removeAll(where: { $0 == quote.text })
            }
        }
        
        categories.removeAll(where: { $0.name == category.name })
        quotes.removeValue(forKey: category.name)
        saveFavorites()
        saveCustomCategories()
        persistCustomQuotes()
        rebuildCategories()
    }
    
    func editCategory(_ category: Category, newName: String) {
        guard category.isCustom else { return } // Нельзя редактировать системные категории
        
        let cleanName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        if !categories.contains(where: { $0.name == cleanName }) {
            // Обновляем название категории
            if let index = categories.firstIndex(where: { $0.name == category.name }) {
                let updatedCategory = Category(name: cleanName, isCustom: true, dateCreated: category.dateCreated)
                categories[index] = updatedCategory
                
                // Перемещаем цитаты в новую категорию
                if let quotesArray = quotes[category.name] {
                    let updatedQuotes = quotesArray.map { quote in
                        Quote(text: quote.text, isCustom: quote.isCustom, category: cleanName, dateCreated: quote.dateCreated)
                    }
                    quotes.removeValue(forKey: category.name)
                    quotes[cleanName] = updatedQuotes
                }
                
                saveCustomCategories()
                persistCustomQuotes()
                rebuildCategories()
            }
        }
    }

    // MARK: - Custom quotes persistence
    private func mergeCustomQuotesFromStorage() {
        // Загружаем пользовательские цитаты
        guard let data = UserDefaults.standard.data(forKey: customQuotesKey),
              let saved = try? JSONDecoder().decode([String: [Quote]].self, from: data) else { return }
        
        for (categoryName, quotesArray) in saved {
            quotes[categoryName] = quotesArray
        }
        
        // Загружаем пользовательские категории
        guard let categoriesData = UserDefaults.standard.data(forKey: customCategoriesKey),
              let savedCategories = try? JSONDecoder().decode([Category].self, from: categoriesData) else { return }
        
        for category in savedCategories {
            if !categories.contains(where: { $0.name == category.name }) {
                categories.append(category)
            }
        }
    }

    private func persistCustomQuotes() {
        var customQuotes: [String: [Quote]] = [:]
        
        for (categoryName, quotesArray) in quotes {
            let customQuotesInCategory = quotesArray.filter { $0.isCustom }
            if !customQuotesInCategory.isEmpty {
                customQuotes[categoryName] = customQuotesInCategory
            }
        }
        
        if let data = try? JSONEncoder().encode(customQuotes) {
            UserDefaults.standard.set(data, forKey: customQuotesKey)
        }
    }
    
    private func saveCustomCategories() {
        let customCategories = categories.filter { $0.isCustom }
        if let data = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(data, forKey: customCategoriesKey)
        }
    }
    
    // MARK: - Cache Management
    private func loadFromCache() -> Bool {
        // Загружаем цитаты из кэша
        if let cachedQuotes = cacheManager.getCachedQuotes() {
            quotes = cachedQuotes
        } else {
            return false
        }
        
        // Загружаем избранное из кэша
        if let cachedFavorites = cacheManager.getCachedFavorites() {
            favorites = cachedFavorites
        }
        
        // Перестраиваем категории
        rebuildCategories()
        
        return true
    }
    
    func clearCache() {
        cacheManager.clearCache(for: CacheManager.CacheKey.quotes.rawValue)
        cacheManager.clearCache(for: CacheManager.CacheKey.favorites.rawValue)
        print("✅ [QUOTES] Кэш очищен")
    }
}

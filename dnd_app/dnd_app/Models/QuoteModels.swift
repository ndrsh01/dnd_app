import Foundation

// MARK: - JSON Quote Models

struct JSONQuotes: Codable {
    let categories: [String: [String]]
}

struct QuoteCategory: Identifiable, Codable, Equatable {
    var id: UUID { UUID() }
    let name: String
    var quotes: [String]
    
    init(name: String, quotes: [String]) {
        self.name = name
        self.quotes = quotes
    }
    
    static func == (lhs: QuoteCategory, rhs: QuoteCategory) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

// MARK: - Quote Manager for JSON

class JSONQuoteManager: ObservableObject {
    @Published var categories: [QuoteCategory] = []
    @Published var selectedCategory: QuoteCategory?
    @Published var currentQuote: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadQuotesFromJSON()
        // При первом запуске копируем данные из Bundle в Documents
        initializeQuotesFile()
    }
    
    func loadQuotesFromJSON() {
        isLoading = true
        errorMessage = nil
        
        // Сначала пытаемся загрузить из Documents directory (пользовательские изменения)
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let quotesPath = documentsPath.appendingPathComponent("quotes.json")
            
            if FileManager.default.fileExists(atPath: quotesPath.path) {
                do {
                    let data = try Data(contentsOf: quotesPath)
                    let jsonQuotes = try JSONDecoder().decode(JSONQuotes.self, from: data)
                    
                    categories = jsonQuotes.categories.map { (name, quotes) in
                        QuoteCategory(name: name, quotes: quotes)
                    }.sorted { $0.name < $1.name }
                    
                    if let firstCategory = categories.first {
                        selectedCategory = firstCategory
                        getRandomQuote(from: firstCategory)
                    }
                    
                    isLoading = false
                    print("✅ Цитаты загружены из Documents directory")
                    return
                } catch {
                    print("⚠️ Ошибка загрузки из Documents: \(error.localizedDescription)")
                    // Продолжаем с загрузкой из Bundle
                }
            }
        }
        
        // Если файл в Documents не найден или произошла ошибка, загружаем из Bundle
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json") else {
            errorMessage = "Файл quotes.json не найден"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonQuotes = try JSONDecoder().decode(JSONQuotes.self, from: data)
            
            categories = jsonQuotes.categories.map { (name, quotes) in
                QuoteCategory(name: name, quotes: quotes)
            }.sorted { $0.name < $1.name }
            
            if let firstCategory = categories.first {
                selectedCategory = firstCategory
                getRandomQuote(from: firstCategory)
            }
            
            isLoading = false
            print("✅ Цитаты загружены из Bundle")
        } catch {
            errorMessage = "Ошибка загрузки цитат: \(error.localizedDescription)"
            isLoading = false
            print("❌ Ошибка загрузки из Bundle: \(error.localizedDescription)")
        }
    }
    
    func getRandomQuote(from category: QuoteCategory? = nil) {
        let targetCategory = category ?? selectedCategory ?? categories.first
        
        guard let category = targetCategory, !category.quotes.isEmpty else {
            currentQuote = "Цитаты не найдены"
            return
        }
        
        let randomIndex = Int.random(in: 0..<category.quotes.count)
        currentQuote = category.quotes[randomIndex]
    }
    
    func getRandomQuoteFromAllCategories() {
        guard !categories.isEmpty else {
            currentQuote = "Цитаты не найдены"
            return
        }
        
        let randomCategoryIndex = Int.random(in: 0..<categories.count)
        let randomCategory = categories[randomCategoryIndex]
        let randomIndex = Int.random(in: 0..<randomCategory.quotes.count)
        currentQuote = randomCategory.quotes[randomIndex]
        selectedCategory = randomCategory
    }
    
    func selectCategory(_ category: QuoteCategory) {
        selectedCategory = category
        getRandomQuote(from: category)
    }
    
    func getQuotesForCategory(_ category: QuoteCategory) -> [String] {
        return category.quotes
    }
    
    func searchQuotes(query: String) -> [String] {
        guard !query.isEmpty else { return [] }
        
        var results: [String] = []
        for category in categories {
            let matchingQuotes = category.quotes.filter { quote in
                quote.localizedCaseInsensitiveContains(query)
            }
            results.append(contentsOf: matchingQuotes)
        }
        return results
    }
    
    // MARK: - Management Methods
    
    func addQuote(_ quote: String, to categoryName: String) {
        let cleanQuote = quote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuote.isEmpty else { return }
        
        if let index = categories.firstIndex(where: { $0.name == categoryName }) {
            var updatedCategory = categories[index]
            updatedCategory.quotes.append(cleanQuote)
            categories[index] = updatedCategory
            saveCustomQuotes()
        }
    }
    
    func removeQuote(_ quote: String, from category: QuoteCategory) {
        if let categoryIndex = categories.firstIndex(where: { $0.name == category.name }) {
            var updatedCategory = categories[categoryIndex]
            updatedCategory.quotes.removeAll { $0 == quote }
            categories[categoryIndex] = updatedCategory
            saveCustomQuotes()
        }
    }
    
    func removeQuotes(at offsets: IndexSet, from category: QuoteCategory) {
        if let categoryIndex = categories.firstIndex(where: { $0.name == category.name }) {
            var updatedCategory = categories[categoryIndex]
            updatedCategory.quotes.remove(atOffsets: offsets)
            categories[categoryIndex] = updatedCategory
            saveCustomQuotes()
        }
    }
    
    func updateQuote(_ oldQuote: String, newText: String, in category: QuoteCategory) {
        let cleanText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }
        
        if let categoryIndex = categories.firstIndex(where: { $0.name == category.name }) {
            if let quoteIndex = categories[categoryIndex].quotes.firstIndex(of: oldQuote) {
                var updatedCategory = categories[categoryIndex]
                updatedCategory.quotes[quoteIndex] = cleanText
                categories[categoryIndex] = updatedCategory
                saveCustomQuotes()
            }
        }
    }
    
    func addCategory(name: String) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        if !categories.contains(where: { $0.name == cleanName }) {
            let newCategory = QuoteCategory(name: cleanName, quotes: [])
            categories.append(newCategory)
            categories.sort { $0.name < $1.name }
            saveCustomQuotes()
        }
    }
    
    func removeCategory(_ category: QuoteCategory) {
        categories.removeAll { $0.name == category.name }
        saveCustomQuotes()
    }
    
    private func saveCustomQuotes() {
        // Сохраняем изменения в quotes.json
        saveToJSON()
        objectWillChange.send()
    }
    
    private func initializeQuotesFile() {
        // Проверяем, существует ли файл в Documents directory
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Не удалось получить путь к documents directory")
            return
        }
        
        let quotesPath = documentsPath.appendingPathComponent("quotes.json")
        
        // Если файл не существует, копируем из Bundle
        if !FileManager.default.fileExists(atPath: quotesPath.path) {
            guard let bundleUrl = Bundle.main.url(forResource: "quotes", withExtension: "json") else {
                print("❌ Файл quotes.json не найден в Bundle")
                return
            }
            
            do {
                try FileManager.default.copyItem(at: bundleUrl, to: quotesPath)
                print("✅ Файл quotes.json скопирован из Bundle в Documents directory")
            } catch {
                print("❌ Ошибка копирования файла: \(error)")
            }
        }
    }
    
    private func saveToJSON() {
        // Создаем структуру данных для сохранения
        var categoriesDict: [String: [String]] = [:]
        
        for category in categories {
            categoriesDict[category.name] = category.quotes
        }
        
        let jsonQuotes = JSONQuotes(categories: categoriesDict)
        
        // Получаем путь к documents directory
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Не удалось получить путь к documents directory")
            return
        }
        
        let quotesPath = documentsPath.appendingPathComponent("quotes.json")
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(jsonQuotes)
            try data.write(to: quotesPath)
            print("✅ Цитаты сохранены в \(quotesPath)")
        } catch {
            print("❌ Ошибка сохранения цитат: \(error)")
        }
    }
}

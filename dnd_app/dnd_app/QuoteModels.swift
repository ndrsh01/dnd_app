import Foundation

// MARK: - JSON Quote Models

struct JSONQuotes: Codable {
    let categories: [String: [String]]
}

struct QuoteCategory: Identifiable, Codable {
    let id = UUID()
    let name: String
    var quotes: [String]
    
    init(name: String, quotes: [String]) {
        self.name = name
        self.quotes = quotes
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
    }
    
    func loadQuotesFromJSON() {
        isLoading = true
        errorMessage = nil
        
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
        } catch {
            errorMessage = "Ошибка загрузки цитат: \(error.localizedDescription)"
            isLoading = false
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
            categories[index].quotes.append(cleanQuote)
            saveCustomQuotes()
        }
    }
    
    func removeQuote(_ quote: String, from category: QuoteCategory) {
        if let categoryIndex = categories.firstIndex(where: { $0.name == category.name }) {
            categories[categoryIndex].quotes.removeAll { $0 == quote }
            saveCustomQuotes()
        }
    }
    
    func updateQuote(_ oldQuote: String, newText: String, in category: QuoteCategory) {
        let cleanText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }
        
        if let categoryIndex = categories.firstIndex(where: { $0.name == category.name }) {
            if let quoteIndex = categories[categoryIndex].quotes.firstIndex(of: oldQuote) {
                categories[categoryIndex].quotes[quoteIndex] = cleanText
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

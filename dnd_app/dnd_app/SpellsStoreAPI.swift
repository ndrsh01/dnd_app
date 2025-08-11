import Foundation

// MARK: - API Models
struct APIResponse<T: Codable>: Codable {
    let spells: [T]?
    let feats: [T]?
    let total: Int?
    let pages: Int?
    let current_page: Int?
}

struct SpellFiltersResponse: Codable {
    let schools: [String]
    let classes: [String]
    let levels: [Int]
}

struct FeatFiltersResponse: Codable {
    let categories: [String]
}

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://your-app-name.railway.app/api" // Замените на ваш URL
    
    private init() {}
    
    func fetch<T: Codable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func post<T: Codable>(_ endpoint: String, body: [String: Any]) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case noData
}

// MARK: - API Store
@MainActor
final class SpellsStoreAPI: ObservableObject {
    @Published var spells: [Spell] = []
    @Published var filteredSpells: [Spell] = []
    @Published var spellFilters = SpellFilters()
    
    @Published var feats: [Feat] = []
    @Published var filteredFeats: [Feat] = []
    @Published var featFilters = FeatFilters()
    
    @Published var availableSchools: [String] = []
    @Published var availableClasses: [String] = []
    @Published var availableFeatCategories: [String] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    
    init() {
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        await loadSpells()
        await loadFeats()
        await loadFilters()
    }
    
    // MARK: - Spells Loading
    func loadSpells() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: APIResponse<Spell> = try await networkManager.fetch("/spells")
            if let spells = response.spells {
                self.spells = spells
                self.applySpellFilters()
            }
            print("✅ [API] Загружено \(spells.count) заклинаний")
        } catch {
            errorMessage = "Ошибка загрузки заклинаний: \(error.localizedDescription)"
            print("❌ [API] Ошибка загрузки заклинаний: \(error)")
        }
        
        isLoading = false
    }
    
    func loadSpellsWithFilters() async {
        isLoading = true
        errorMessage = nil
        
        var queryItems: [String] = []
        
        if !spellFilters.searchText.isEmpty {
            queryItems.append("search=\(spellFilters.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        for level in spellFilters.selectedLevels {
            queryItems.append("level=\(level)")
        }
        
        for school in spellFilters.selectedSchools {
            queryItems.append("school=\(school.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        for className in spellFilters.selectedClasses {
            queryItems.append("class=\(className.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        if spellFilters.concentrationOnly {
            queryItems.append("concentration=true")
        }
        
        if spellFilters.ritualOnly {
            queryItems.append("ritual=true")
        }
        
        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        
        do {
            let response: APIResponse<Spell> = try await networkManager.fetch("/spells\(queryString)")
            if let spells = response.spells {
                self.filteredSpells = spells
            }
        } catch {
            errorMessage = "Ошибка фильтрации заклинаний: \(error.localizedDescription)"
            print("❌ [API] Ошибка фильтрации заклинаний: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Feats Loading
    func loadFeats() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: APIResponse<Feat> = try await networkManager.fetch("/feats")
            if let feats = response.feats {
                self.feats = feats
                self.applyFeatFilters()
            }
            print("✅ [API] Загружено \(feats.count) умений")
        } catch {
            errorMessage = "Ошибка загрузки умений: \(error.localizedDescription)"
            print("❌ [API] Ошибка загрузки умений: \(error)")
        }
        
        isLoading = false
    }
    
    func loadFeatsWithFilters() async {
        isLoading = true
        errorMessage = nil
        
        var queryItems: [String] = []
        
        if !featFilters.searchText.isEmpty {
            queryItems.append("search=\(featFilters.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        for category in featFilters.selectedCategories {
            queryItems.append("category=\(category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        
        do {
            let response: APIResponse<Feat> = try await networkManager.fetch("/feats\(queryString)")
            if let feats = response.feats {
                self.filteredFeats = feats
            }
        } catch {
            errorMessage = "Ошибка фильтрации умений: \(error.localizedDescription)"
            print("❌ [API] Ошибка фильтрации умений: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Filters Loading
    func loadFilters() async {
        do {
            let spellFilters: SpellFiltersResponse = try await networkManager.fetch("/spells/filters")
            self.availableSchools = spellFilters.schools
            self.availableClasses = spellFilters.classes
            
            let featFilters: FeatFiltersResponse = try await networkManager.fetch("/feats/filters")
            self.availableFeatCategories = featFilters.categories
        } catch {
            errorMessage = "Ошибка загрузки фильтров: \(error.localizedDescription)"
            print("❌ [API] Ошибка загрузки фильтров: \(error)")
        }
    }
    
    // MARK: - Spell Filters
    func updateSpellSearchText(_ text: String) {
        spellFilters.searchText = text
        Task {
            await loadSpellsWithFilters()
        }
    }
    
    func toggleSpellLevelFilter(_ level: Int) {
        spellFilters.toggleLevelFilter(level)
        Task {
            await loadSpellsWithFilters()
        }
    }
    
    func toggleSpellSchoolFilter(_ school: String) {
        spellFilters.toggleSchoolFilter(school)
        Task {
            await loadSpellsWithFilters()
        }
    }
    
    func toggleSpellClassFilter(_ className: String) {
        spellFilters.toggleClassFilter(className)
        Task {
            await loadSpellsWithFilters()
        }
    }
    
    func toggleSpellConcentrationFilter() {
        spellFilters.concentrationOnly.toggle()
        Task {
            await loadSpellsWithFilters()
        }
    }
    
    func toggleSpellRitualFilter() {
        spellFilters.ritualOnly.toggle()
        Task {
            await loadSpellsWithFilters()
        }
    }
    
    func clearSpellFilters() {
        spellFilters.clear()
        Task {
            await loadSpellsWithFilters()
        }
    }
    
    func applySpellFilters() {
        // Локальная фильтрация для быстрого отклика
        filteredSpells = spells.filter { spell in
            if !spellFilters.searchText.isEmpty {
                let searchText = spellFilters.searchText.lowercased()
                if !spell.name.lowercased().contains(searchText) && 
                   !spell.description.lowercased().contains(searchText) {
                    return false
                }
            }
            
            if !spellFilters.selectedLevels.isEmpty && !spellFilters.selectedLevels.contains(spell.level) {
                return false
            }
            
            if !spellFilters.selectedSchools.isEmpty && !spellFilters.selectedSchools.contains(spell.school) {
                return false
            }
            
            if !spellFilters.selectedClasses.isEmpty {
                let spellClasses = Set(spell.classes)
                let selectedClasses = spellFilters.selectedClasses
                if spellClasses.intersection(selectedClasses).isEmpty {
                    return false
                }
            }
            
            if spellFilters.concentrationOnly && !spell.concentration {
                return false
            }
            
            if spellFilters.ritualOnly && !spell.ritual {
                return false
            }
            
            return true
        }
    }
    
    // MARK: - Feat Filters
    func updateFeatSearchText(_ text: String) {
        featFilters.searchText = text
        Task {
            await loadFeatsWithFilters()
        }
    }
    
    func toggleFeatCategoryFilter(_ category: String) {
        featFilters.toggleCategoryFilter(category)
        Task {
            await loadFeatsWithFilters()
        }
    }
    
    func clearFeatFilters() {
        featFilters.clear()
        Task {
            await loadFeatsWithFilters()
        }
    }
    
    func applyFeatFilters() {
        // Локальная фильтрация для быстрого отклика
        filteredFeats = feats.filter { feat in
            if !featFilters.searchText.isEmpty {
                let searchText = featFilters.searchText.lowercased()
                if !feat.name.lowercased().contains(searchText) && 
                   !feat.description.lowercased().contains(searchText) {
                    return false
                }
            }
            
            if !featFilters.selectedCategories.isEmpty && !featFilters.selectedCategories.contains(feat.category) {
                return false
            }
            
            return true
        }
    }
    
    // MARK: - User Management
    func createUser(username: String, email: String) async throws -> User {
        let body = ["username": username, "email": email]
        let user: User = try await networkManager.post("/users", body: body)
        return user
    }
    
    func getUserSpells(userId: Int) async throws -> [Spell] {
        let response: APIResponse<Spell> = try await networkManager.fetch("/users/\(userId)/spells")
        return response.spells ?? []
    }
    
    func addSpellToUser(userId: Int, spellId: Int, isFavorite: Bool = false, notes: String = "") async throws {
        let body = ["is_favorite": isFavorite, "notes": notes]
        let _: [String: String] = try await networkManager.post("/users/\(userId)/spells/\(spellId)", body: body)
    }
    
    func getUserFeats(userId: Int) async throws -> [Feat] {
        let response: APIResponse<Feat> = try await networkManager.fetch("/users/\(userId)/feats")
        return response.feats ?? []
    }
    
    func addFeatToUser(userId: Int, featId: Int, isFavorite: Bool = false, notes: String = "") async throws {
        let body = ["is_favorite": isFavorite, "notes": notes]
        let _: [String: String] = try await networkManager.post("/users/\(userId)/feats/\(featId)", body: body)
    }
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let created_at: String
}

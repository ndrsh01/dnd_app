
import Foundation

// MARK: - Store
@MainActor
final class CompendiumStore: ObservableObject {
    @Published var spells: [Spell] = []
    @Published var filteredSpells: [Spell] = []
    @Published var spellFilters = SpellFilters()
    
    @Published var backgrounds: [Background] = []
    @Published var filteredBackgrounds: [Background] = []
    @Published var backgroundFilters = BackgroundFilters()
    
    @Published var feats: [Feat] = []
    @Published var filteredFeats: [Feat] = []
    @Published var featFilters = FeatFilters()
    
    @Published var availableSchools: [String] = []
    @Published var availableClasses: [String] = []
    @Published var availableFeatCategories: [String] = []
    
    private let cacheManager = CacheManager.shared

    init() {
        loadData()
    }

    private func loadData() {
        loadSpells()
        loadBackgrounds()
        loadFeats()
        loadCachedFilters()
    }

    // MARK: - Generic Loader
    /// Asynchronously loads a decodable array either from cache or from a JSON file in the bundle.
    /// - Returns: Tuple containing the loaded array and a flag indicating whether the data came from cache.
    private func loadDecodableArray<T: Decodable>(
        fileName: String,
        cacheGetter: () -> [T]?,
        cacheSetter: @escaping ([T]) -> Void
    ) async -> ([T], Bool)? {
        if let cached = cacheGetter() {
            return (cached, true)
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ [\(fileName.uppercased())] Не найден файл \(fileName).json")
            return nil
        }

        do {
            let data = try await Task.detached(priority: .background) {
                try Data(contentsOf: url)
            }.value
            let items = try JSONDecoder().decode([T].self, from: data)
            cacheSetter(items)
            return (items, false)
        } catch {
            print("❌ [\(fileName.uppercased())] Ошибка загрузки: \(error)")
            return nil
        }
    }

    // MARK: - Spells Loading
    private func loadSpells() {
        Task {
            if let (spells, fromCache) = await loadDecodableArray(
                fileName: "spells",
                cacheGetter: cacheManager.getCachedSpells,
                cacheSetter: cacheManager.cacheSpells
            ) {
                await MainActor.run {
                    self.spells = spells
                    self.updateAvailableFilters()
                    self.applySpellFilters()
                    let message = fromCache
                        ? "✅ [SPELLS] Загружено \(spells.count) заклинаний из кэша"
                        : "✅ [SPELLS] Загружено \(spells.count) заклинаний из файла и закэшировано"
                    print(message)
                }
            }
        }
    }

    // MARK: - Backgrounds Loading
    private func loadBackgrounds() {
        Task {
            if let (backgrounds, fromCache) = await loadDecodableArray(
                fileName: "backgrounds",
                cacheGetter: cacheManager.getCachedBackgrounds,
                cacheSetter: cacheManager.cacheBackgrounds
            ) {
                await MainActor.run {
                    self.backgrounds = backgrounds
                    self.applyBackgroundFilters()
                    let message = fromCache
                        ? "✅ [BACKGROUNDS] Загружено \(backgrounds.count) предысторий из кэша"
                        : "✅ [BACKGROUNDS] Загружено \(backgrounds.count) предысторий из файла и закэшировано"
                    print(message)
                }
            }
        }
    }

    // MARK: - Feats Loading
    private func loadFeats() {
        Task {
            if let (feats, fromCache) = await loadDecodableArray(
                fileName: "feats",
                cacheGetter: cacheManager.getCachedFeats,
                cacheSetter: cacheManager.cacheFeats
            ) {
                let categories = Set(feats.map { $0.category })
                await MainActor.run {
                    self.feats = feats
                    self.availableFeatCategories = Array(categories).sorted()
                    self.applyFeatFilters()
                    let message = fromCache
                        ? "✅ [FEATS] Загружено \(feats.count) черт из кэша"
                        : "✅ [FEATS] Загружено \(feats.count) черт из \(categories.count) категорий и закэшировано"
                    print(message)
                }
            }
        }
    }
    
    // MARK: - Filter Updates
    private func updateAvailableFilters() {
        let schools = Set(spells.map { $0.school })
        availableSchools = Array(schools).sorted()
        
        let classes = Set(spells.flatMap { $0.classes })
        availableClasses = Array(classes).sorted()
    }
    
    // MARK: - Background Filters
    func updateBackgroundSearchText(_ text: String) {
        backgroundFilters.searchText = text
        applyBackgroundFilters()
    }
    
    func clearBackgroundFilters() {
        backgroundFilters.clear()
        applyBackgroundFilters()
    }

    func applyBackgroundFilters() {
        let searchText = backgroundFilters.searchText.lowercased()

        filteredBackgrounds = backgrounds.filter { background in
            // Поиск по тексту
            if !searchText.isEmpty {
                if !background.name.lowercased().contains(searchText) &&
                   !background.description.lowercased().contains(searchText) &&
                   !background.trait.lowercased().contains(searchText) {
                    return false
                }
            }

            return true
        }
    }
    
    // MARK: - Spell Filters
    func updateSpellSearchText(_ text: String) {
        spellFilters.searchText = text
        applySpellFilters()
    }
    
    func toggleSpellLevelFilter(_ level: Int) {
        spellFilters.toggleLevelFilter(level)
        applySpellFilters()
    }
    
    func toggleSpellSchoolFilter(_ school: String) {
        spellFilters.toggleSchoolFilter(school)
        applySpellFilters()
    }
    
    func toggleSpellClassFilter(_ className: String) {
        spellFilters.toggleClassFilter(className)
        applySpellFilters()
    }
    
    func toggleSpellConcentrationFilter() {
        spellFilters.concentrationOnly.toggle()
        applySpellFilters()
    }
    
    func toggleSpellRitualFilter() {
        spellFilters.ritualOnly.toggle()
        applySpellFilters()
    }
    
    func clearSpellFilters() {
        spellFilters.clear()
        applySpellFilters()
    }

    func applySpellFilters() {
        let searchText = spellFilters.searchText.lowercased()
        let selectedLevels = spellFilters.selectedLevels
        let selectedSchools = spellFilters.selectedSchools
        let selectedClasses = spellFilters.selectedClasses
        let concentrationOnly = spellFilters.concentrationOnly
        let ritualOnly = spellFilters.ritualOnly

        filteredSpells = spells.filter { spell in
            // Поиск по тексту
            if !searchText.isEmpty {
                if !spell.name.lowercased().contains(searchText) &&
                   !spell.description.lowercased().contains(searchText) {
                    return false
                }
            }

            // Фильтр по уровню
            if !selectedLevels.isEmpty && !selectedLevels.contains(spell.level) {
                return false
            }

            // Фильтр по школе
            if !selectedSchools.isEmpty && !selectedSchools.contains(spell.school) {
                return false
            }

            // Фильтр по классу
            if !selectedClasses.isEmpty {
                let spellClasses = Set(spell.classes)
                if spellClasses.intersection(selectedClasses).isEmpty {
                    return false
                }
            }

            // Фильтр концентрации
            if concentrationOnly && !spell.concentration {
                return false
            }

            // Фильтр ритуала
            if ritualOnly && !spell.ritual {
                return false
            }

            return true
        }

        // Кэшируем фильтры заклинаний
        cacheManager.cacheSpellFilters(spellFilters)
    }
    
    // MARK: - Feat Filters
    func updateFeatSearchText(_ text: String) {
        featFilters.searchText = text
        applyFeatFilters()
    }
    
    func toggleFeatCategoryFilter(_ category: String) {
        featFilters.toggleCategoryFilter(category)
        applyFeatFilters()
    }
    
    func clearFeatFilters() {
        featFilters.clear()
        applyFeatFilters()
    }

    func applyFeatFilters() {
        let searchText = featFilters.searchText.lowercased()
        let selectedCategories = featFilters.selectedCategories

        filteredFeats = feats.filter { feat in
            // Поиск по тексту
            if !searchText.isEmpty {
                if !feat.name.lowercased().contains(searchText) &&
                   !feat.description.lowercased().contains(searchText) {
                    return false
                }
            }

            // Фильтр по категории
            if !selectedCategories.isEmpty && !selectedCategories.contains(feat.category) {
                return false
            }

            return true
        }

        // Кэшируем фильтры черт
        cacheManager.cacheFeatFilters(featFilters)
    }
    
    // MARK: - Cache Management
    private func loadCachedFilters() {
        // Загружаем кэшированные фильтры заклинаний
        if let cachedSpellFilters = cacheManager.getCachedSpellFilters() {
            spellFilters = cachedSpellFilters
            print("✅ [CACHE] Загружены кэшированные фильтры заклинаний")
        }
        
        // Загружаем кэшированные фильтры черт
        if let cachedFeatFilters = cacheManager.getCachedFeatFilters() {
            featFilters = cachedFeatFilters
            print("✅ [CACHE] Загружены кэшированные фильтры черт")
        }
    }
    
    func clearAllCaches() {
        cacheManager.clearAllCaches()
        print("✅ [CACHE] Все кэши очищены")
    }
}

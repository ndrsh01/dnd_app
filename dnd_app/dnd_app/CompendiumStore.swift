
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
    
    // MARK: - Spells Loading
    private func loadSpells() {
        // Сначала пытаемся загрузить из кэша
        if let cachedSpells = cacheManager.getCachedSpells() {
            self.spells = cachedSpells
            self.updateAvailableFilters()
            self.applySpellFilters()
            print("✅ [SPELLS] Загружено \(cachedSpells.count) заклинаний из кэша")
            return
        }
        
        // Если кэша нет, загружаем из файла
        guard let url = Bundle.main.url(forResource: "spells", withExtension: "json") else {
            print("❌ [SPELLS] Не найден файл spells.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let spells = try JSONDecoder().decode([Spell].self, from: data)
            
            self.spells = spells
            self.updateAvailableFilters()
            self.applySpellFilters()
            
            // Кэшируем заклинания
            cacheManager.cacheSpells(spells)
            
            print("✅ [SPELLS] Загружено \(spells.count) заклинаний из файла и закэшировано")
        } catch {
            print("❌ [SPELLS] Ошибка загрузки заклинаний: \(error)")
        }
    }
    
    // MARK: - Backgrounds Loading
    private func loadBackgrounds() {
        // Сначала пытаемся загрузить из кэша
        if let cachedBackgrounds = cacheManager.getCachedBackgrounds() {
            self.backgrounds = cachedBackgrounds
            self.applyBackgroundFilters()
            print("✅ [BACKGROUNDS] Загружено \(cachedBackgrounds.count) предысторий из кэша")
            return
        }
        
        // Если кэша нет, загружаем из файла
        guard let url = Bundle.main.url(forResource: "backgrounds", withExtension: "json") else {
            print("❌ [BACKGROUNDS] Не найден файл backgrounds.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let backgrounds = try JSONDecoder().decode([Background].self, from: data)
            
            self.backgrounds = backgrounds
            self.applyBackgroundFilters()
            
            // Кэшируем предыстории
            cacheManager.cacheBackgrounds(backgrounds)
            
            print("✅ [BACKGROUNDS] Загружено \(backgrounds.count) предысторий из файла и закэшировано")
        } catch {
            print("❌ [BACKGROUNDS] Ошибка загрузки предысторий: \(error)")
        }
    }
    
    // MARK: - Feats Loading
    private func loadFeats() {
        // Сначала пытаемся загрузить из кэша
        if let cachedFeats = cacheManager.getCachedFeats() {
            self.feats = cachedFeats
            let categories = Set(cachedFeats.map { $0.category })
            self.availableFeatCategories = Array(categories).sorted()
            self.applyFeatFilters()
            print("✅ [FEATS] Загружено \(cachedFeats.count) черт из кэша")
            return
        }
        
        // Если кэша нет, загружаем из файла
        guard let url = Bundle.main.url(forResource: "feats", withExtension: "json") else {
            print("❌ [FEATS] Не найден файл feats.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let feats = try JSONDecoder().decode([Feat].self, from: data)
            
            self.feats = feats
            let categories = Set(feats.map { $0.category })
            self.availableFeatCategories = Array(categories).sorted()
            self.applyFeatFilters()
            
            // Кэшируем черты
            cacheManager.cacheFeats(feats)
            
            print("✅ [FEATS] Загружено \(feats.count) черт из \(categories.count) категорий и закэшировано")
        } catch {
            print("❌ [FEATS] Ошибка загрузки черт: \(error)")
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

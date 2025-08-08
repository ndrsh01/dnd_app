
import Foundation

// MARK: - Store
@MainActor
final class SpellsStore: ObservableObject {
    @Published var spells: [Spell] = []
    @Published var filteredSpells: [Spell] = []
    @Published var spellFilters = SpellFilters()
    
    @Published var feats: [Feat] = []
    @Published var filteredFeats: [Feat] = []
    @Published var featFilters = FeatFilters()
    
    @Published var availableSchools: [String] = []
    @Published var availableClasses: [String] = []
    @Published var availableFeatCategories: [String] = []

    init() {
        loadData()
    }
    
    private func loadData() {
        Task {
            await loadSpells()
            await loadFeats()
        }
    }
    
    // MARK: - Spells Loading
    func loadSpells() async {
        guard let url = Bundle.main.url(forResource: "spells", withExtension: "json") else {
            print("❌ [SPELLS] Не найден файл spells.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let spells = try JSONDecoder().decode([Spell].self, from: data)
            
            await MainActor.run {
                self.spells = spells
                self.updateAvailableFilters()
                self.applySpellFilters()
            }
            
            print("✅ [SPELLS] Загружено \(spells.count) заклинаний")
        } catch {
            print("❌ [SPELLS] Ошибка загрузки заклинаний: \(error)")
        }
    }
    
    // MARK: - Feats Loading
    func loadFeats() async {
        guard let url = Bundle.main.url(forResource: "feats", withExtension: "json") else {
            print("❌ [FEATS] Не найден файл feats.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let featsDict = try JSONDecoder().decode([String: [[String: String]]].self, from: data)
            
            var allFeats: [Feat] = []
            var categories: Set<String> = []
            
            for (category, featsArray) in featsDict {
                categories.insert(category)
                for featDict in featsArray {
                    if let name = featDict["название"], let description = featDict["описание"] {
                        let feat = Feat(name: name, description: description, category: category)
                        allFeats.append(feat)
                    }
                }
            }
            
            await MainActor.run {
                self.feats = allFeats
                self.availableFeatCategories = Array(categories).sorted()
                self.applyFeatFilters()
            }
            
            print("✅ [FEATS] Загружено \(allFeats.count) умений из \(categories.count) категорий")
        } catch {
            print("❌ [FEATS] Ошибка загрузки умений: \(error)")
        }
    }
    
    // MARK: - Filter Updates
    private func updateAvailableFilters() {
        let schools = Set(spells.map { $0.school })
        availableSchools = Array(schools).sorted()
        
        let classes = Set(spells.flatMap { $0.classes })
        availableClasses = Array(classes).sorted()
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
        filteredSpells = spells.filter { spell in
            // Поиск по тексту
            if !spellFilters.searchText.isEmpty {
                let searchText = spellFilters.searchText.lowercased()
                if !spell.name.lowercased().contains(searchText) && 
                   !spell.description.lowercased().contains(searchText) {
                    return false
                }
            }
            
            // Фильтр по уровню
            if !spellFilters.selectedLevels.isEmpty && !spellFilters.selectedLevels.contains(spell.level) {
                return false
            }
            
            // Фильтр по школе
            if !spellFilters.selectedSchools.isEmpty && !spellFilters.selectedSchools.contains(spell.school) {
                return false
            }
            
            // Фильтр по классу
            if !spellFilters.selectedClasses.isEmpty {
                let spellClasses = Set(spell.classes)
                let selectedClasses = spellFilters.selectedClasses
                if spellClasses.intersection(selectedClasses).isEmpty {
                    return false
                }
            }
            
            // Фильтр концентрации
            if spellFilters.concentrationOnly && !spell.concentration {
                return false
            }
            
            // Фильтр ритуала
            if spellFilters.ritualOnly && !spell.ritual {
                return false
            }
            
            return true
        }
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
        filteredFeats = feats.filter { feat in
            // Поиск по тексту
            if !featFilters.searchText.isEmpty {
                let searchText = featFilters.searchText.lowercased()
                if !feat.name.lowercased().contains(searchText) && 
                   !feat.description.lowercased().contains(searchText) {
                    return false
                }
            }
            
            // Фильтр по категории
            if !featFilters.selectedCategories.isEmpty && !featFilters.selectedCategories.contains(feat.category) {
                return false
            }
            
            return true
        }
    }
}

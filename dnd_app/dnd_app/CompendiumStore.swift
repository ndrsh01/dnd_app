import Foundation

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
    
    @Published var monsters: [Monster] = []
    @Published var filteredMonsters: [Monster] = []
    @Published var monsterFilters = MonsterFilters()
    
    @Published var isLoading = false
    
    private let cacheManager = CacheManager.shared
    
    init() {
        loadAllData()
    }
    
    private func loadAllData() {
        isLoading = true
        
        loadSpells()
        loadBackgrounds()
        loadFeats()
        loadMonsters()
        
        isLoading = false
    }
    
    private func loadSpells() {
        // Пытаемся загрузить из кэша
        if let cachedSpells = cacheManager.getCachedSpells() {
            self.spells = cachedSpells
            self.filteredSpells = cachedSpells
            return
        }
        
        // Загружаем из файла
        guard let url = Bundle.main.url(forResource: "spells", withExtension: "json") else {
            print("❌ [SPELLS] Не найден файл spells.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let loadedSpells = try JSONDecoder().decode([Spell].self, from: data)
            
            self.spells = loadedSpells
            self.filteredSpells = loadedSpells
            
            // Кэшируем
            cacheManager.cacheSpells(loadedSpells)
            print("✅ [SPELLS] Загружено \(loadedSpells.count) заклинаний")
        } catch {
            print("❌ [SPELLS] Ошибка загрузки: \(error)")
        }
    }
    
    private func loadBackgrounds() {
        // Пытаемся загрузить из кэша
        if let cachedBackgrounds = cacheManager.getCachedBackgrounds() {
            self.backgrounds = cachedBackgrounds
            self.filteredBackgrounds = cachedBackgrounds
            return
        }
        
        // Загружаем из файла
        guard let url = Bundle.main.url(forResource: "backgrounds", withExtension: "json") else {
            print("❌ [BACKGROUNDS] Не найден файл backgrounds.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let loadedBackgrounds = try JSONDecoder().decode([Background].self, from: data)
            
            self.backgrounds = loadedBackgrounds
            self.filteredBackgrounds = loadedBackgrounds
            
            // Кэшируем
            cacheManager.cacheBackgrounds(loadedBackgrounds)
            print("✅ [BACKGROUNDS] Загружено \(loadedBackgrounds.count) предысторий")
        } catch {
            print("❌ [BACKGROUNDS] Ошибка загрузки: \(error)")
        }
    }
    
    private func loadFeats() {
        // Пытаемся загрузить из кэша
        if let cachedFeats = cacheManager.getCachedFeats() {
            self.feats = cachedFeats
            self.filteredFeats = cachedFeats
            return
        }
        
        // Загружаем из файла
        guard let url = Bundle.main.url(forResource: "feats", withExtension: "json") else {
            print("❌ [FEATS] Не найден файл feats.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let loadedFeats = try JSONDecoder().decode([Feat].self, from: data)
            
            self.feats = loadedFeats
            self.filteredFeats = loadedFeats
            
            // Кэшируем
            cacheManager.cacheFeats(loadedFeats)
            print("✅ [FEATS] Загружено \(loadedFeats.count) черт")
        } catch {
            print("❌ [FEATS] Ошибка загрузки: \(error)")
        }
    }
    
    // MARK: - Update Methods
    
    func updateSpellSearchText(_ text: String) {
        spellFilters.searchText = text
        applySpellFilters()
    }
    
    func updateBackgroundSearchText(_ text: String) {
        backgroundFilters.searchText = text
        applyBackgroundFilters()
    }
    
    func updateFeatSearchText(_ text: String) {
        featFilters.searchText = text
        applyFeatFilters()
    }
    
    func toggleSpellLevelFilter(_ level: Int) {
        if spellFilters.selectedLevels.contains(level) {
            spellFilters.selectedLevels.remove(level)
        } else {
            spellFilters.selectedLevels.insert(level)
        }
        applySpellFilters()
    }
    
    func toggleSpellSchoolFilter(_ school: String) {
        if spellFilters.selectedSchools.contains(school) {
            spellFilters.selectedSchools.remove(school)
        } else {
            spellFilters.selectedSchools.insert(school)
        }
        applySpellFilters()
    }
    
    func toggleSpellClassFilter(_ className: String) {
        if spellFilters.selectedClasses.contains(className) {
            spellFilters.selectedClasses.remove(className)
        } else {
            spellFilters.selectedClasses.insert(className)
        }
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
    
    func toggleFeatCategoryFilter(_ category: String) {
        // Для простоты пока не реализуем категории черт
        applyFeatFilters()
    }
    
    var availableFeatCategories: [String] {
        // Возвращаем пустой массив, так как категории черт не определены
        return []
    }
    
    var availableSpellSchools: [String] {
        let schools = Set(spells.map { $0.school })
        return Array(schools).sorted()
    }
    
    var availableSpellClasses: [String] {
        let allClasses = spells.flatMap { $0.classes }
        let uniqueClasses = Set(allClasses)
        return Array(uniqueClasses).sorted()
    }
    
    func clearSpellFilters() {
        spellFilters = SpellFilters()
        applySpellFilters()
    }
    
    func clearBackgroundFilters() {
        backgroundFilters = BackgroundFilters()
        applyBackgroundFilters()
    }
    
    func clearFeatFilters() {
        featFilters = FeatFilters()
        applyFeatFilters()
    }
    
    // MARK: - Filtering
    
    func applySpellFilters() {
        filteredSpells = spells.filter { spell in
            // Фильтр по уровню
            if !spellFilters.selectedLevels.isEmpty && !spellFilters.selectedLevels.contains(spell.level) {
                return false
            }
            
            // Фильтр по школе
            if !spellFilters.selectedSchools.isEmpty && !spellFilters.selectedSchools.contains(spell.school) {
                return false
            }
            
            // Фильтр по классам
            if !spellFilters.selectedClasses.isEmpty {
                let hasMatchingClass = spellFilters.selectedClasses.contains { filterClass in
                    spell.classes.contains { spellClass in
                        spellClass.lowercased().contains(filterClass.lowercased())
                    }
                }
                if !hasMatchingClass {
                    return false
                }
            }
            
            // Поиск по тексту
            if !spellFilters.searchText.isEmpty {
                let searchText = spellFilters.searchText.lowercased()
                return spell.name.lowercased().contains(searchText) ||
                       spell.description.lowercased().contains(searchText)
            }
            
            return true
        }
    }
    
    func applyBackgroundFilters() {
        filteredBackgrounds = backgrounds.filter { background in
            // Поиск по тексту
            if !backgroundFilters.searchText.isEmpty {
                let searchText = backgroundFilters.searchText.lowercased()
                return background.name.lowercased().contains(searchText) ||
                       background.description.lowercased().contains(searchText)
            }
            
            return true
        }
    }
    
    func applyFeatFilters() {
        filteredFeats = feats.filter { feat in
            // Поиск по тексту
            if !featFilters.searchText.isEmpty {
                let searchText = featFilters.searchText.lowercased()
                return feat.name.lowercased().contains(searchText) ||
                       feat.description.lowercased().contains(searchText)
            }
            
            return true
        }
    }
    
    // MARK: - Monster Methods
    
    private func loadMonsters() {
        // Пытаемся загрузить из кэша
        if let cachedMonsters = cacheManager.getCachedMonsters() {
            self.monsters = cachedMonsters
            self.filteredMonsters = cachedMonsters
            return
        }
        
        // Загружаем из файла
        guard let url = Bundle.main.url(forResource: "bestiary_5e", withExtension: "ndjson") else {
            print("❌ [MONSTERS] Не найден файл bestiary_5e.ndjson")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let content = String(data: data, encoding: .utf8) ?? ""
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            var loadedMonsters: [Monster] = []
            
            for line in lines {
                if let lineData = line.data(using: .utf8) {
                    do {
                        let monster = try JSONDecoder().decode(Monster.self, from: lineData)
                        loadedMonsters.append(monster)
                    } catch {
                        print("❌ [MONSTERS] Ошибка парсинга строки: \(error)")
                        continue
                    }
                }
            }
            
            self.monsters = loadedMonsters
            self.filteredMonsters = loadedMonsters
            
            // Кэшируем
            cacheManager.cacheMonsters(loadedMonsters)
            print("✅ [MONSTERS] Загружено \(loadedMonsters.count) монстров")
        } catch {
            print("❌ [MONSTERS] Ошибка загрузки: \(error)")
        }
    }
    
    func updateMonsterSearchText(_ text: String) {
        monsterFilters.searchText = text
        applyMonsterFilters()
    }
    
    func updateMonsterSizeFilter(_ size: String) {
        if monsterFilters.selectedSizes.contains(size) {
            monsterFilters.selectedSizes.removeAll { $0 == size }
        } else {
            monsterFilters.selectedSizes.append(size)
        }
        applyMonsterFilters()
    }
    
    func updateMonsterTypeFilter(_ type: String) {
        if monsterFilters.selectedTypes.contains(type) {
            monsterFilters.selectedTypes.removeAll { $0 == type }
        } else {
            monsterFilters.selectedTypes.append(type)
        }
        applyMonsterFilters()
    }
    
    func updateMonsterCRFilter(_ cr: String) {
        if monsterFilters.selectedCRs.contains(cr) {
            monsterFilters.selectedCRs.removeAll { $0 == cr }
        } else {
            monsterFilters.selectedCRs.append(cr)
        }
        applyMonsterFilters()
    }
    
    func updateMonsterAlignmentFilter(_ alignment: String) {
        if monsterFilters.selectedAlignments.contains(alignment) {
            monsterFilters.selectedAlignments.removeAll { $0 == alignment }
        } else {
            monsterFilters.selectedAlignments.append(alignment)
        }
        applyMonsterFilters()
    }
    
    func clearMonsterFilters() {
        monsterFilters = MonsterFilters()
        applyMonsterFilters()
    }
    
    func applyMonsterFilters() {
        filteredMonsters = monsters.filter { monster in
            // Фильтр по размеру
            if !monsterFilters.selectedSizes.isEmpty && !monsterFilters.selectedSizes.contains(monster.size) {
                return false
            }
            
            // Фильтр по типу
            if !monsterFilters.selectedTypes.isEmpty && !monsterFilters.selectedTypes.contains(monster.type) {
                return false
            }
            
            // Фильтр по CR
            if !monsterFilters.selectedCRs.isEmpty && !monsterFilters.selectedCRs.contains(monster.challenge.cr) {
                return false
            }
            
            // Фильтр по мировоззрению
            if !monsterFilters.selectedAlignments.isEmpty && !monsterFilters.selectedAlignments.contains(monster.alignment) {
                return false
            }
            
            // Поиск по тексту
            if !monsterFilters.searchText.isEmpty {
                let searchText = monsterFilters.searchText.lowercased()
                return monster.name.lowercased().contains(searchText) ||
                       monster.subtitle.lowercased().contains(searchText) ||
                       monster.type.lowercased().contains(searchText)
            }
            
            return true
        }
    }
}
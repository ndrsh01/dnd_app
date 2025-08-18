import Foundation

@MainActor
final class SpellStore: FilterStore {
    @Published var spells: [Spell] = []
    @Published var filteredSpells: [Spell] = []
    @Published var spellFilters = SpellFilters()

    @Published var availableSchools: [String] = []
    @Published var availableClasses: [String] = []

    override init() {
        super.init()
        loadSpells()
        loadCachedFilters()
    }

    private func loadSpells() {
        Task {
            if let (spells, fromCache) = await loadDecodableArray(
                fileName: "spells",
                cacheGetter: cacheManager.getCachedSpells,
                cacheSetter: cacheManager.cacheSpells
            ) as ([Spell], Bool)? {
                self.spells = spells
                updateAvailableFilters()
                await applyFiltersAsync()
                let message = fromCache
                    ? "✅ [SPELLS] Загружено \(spells.count) заклинаний из кэша"
                    : "✅ [SPELLS] Загружено \(spells.count) заклинаний из файла и закэшировано"
                print(message)
            }
        }
    }

    private func updateAvailableFilters() {
        let schools = Set(spells.map { $0.school })
        availableSchools = Array(schools).sorted()

        let classes = Set(spells.flatMap { $0.classes })
        availableClasses = Array(classes).sorted()
    }

    func updateSpellSearchText(_ text: String) {
        spellFilters.searchText = text
        Task { await applyFiltersAsync() }
    }

    func toggleSpellLevelFilter(_ level: Int) {
        spellFilters.toggleLevelFilter(level)
        Task { await applyFiltersAsync() }
    }

    func toggleSpellSchoolFilter(_ school: String) {
        spellFilters.toggleSchoolFilter(school)
        Task { await applyFiltersAsync() }
    }

    func toggleSpellClassFilter(_ className: String) {
        spellFilters.toggleClassFilter(className)
        Task { await applyFiltersAsync() }
    }

    func toggleSpellConcentrationFilter() {
        spellFilters.concentrationOnly.toggle()
        Task { await applyFiltersAsync() }
    }

    func toggleSpellRitualFilter() {
        spellFilters.ritualOnly.toggle()
        Task { await applyFiltersAsync() }
    }

    func clearSpellFilters() {
        spellFilters.clear()
        Task { await applyFiltersAsync() }
    }

    private func loadCachedFilters() {
        if let cachedSpellFilters = cacheManager.getCachedSpellFilters() {
            spellFilters = cachedSpellFilters
            print("✅ [CACHE] Загружены кэшированные фильтры заклинаний")
        }
    }

    private func applyFiltersAsync() async {
        let spells = self.spells
        let filters = self.spellFilters

        let result = await Task.detached(priority: .userInitiated) -> [Spell] in
            let searchText = filters.searchText.lowercased()
            let selectedLevels = filters.selectedLevels
            let selectedSchools = filters.selectedSchools
            let selectedClasses = filters.selectedClasses
            let concentrationOnly = filters.concentrationOnly
            let ritualOnly = filters.ritualOnly

            return spells.filter { spell in
                if !searchText.isEmpty {
                    if !spell.name.lowercased().contains(searchText) &&
                       !spell.description.lowercased().contains(searchText) {
                        return false
                    }
                }

                if !selectedLevels.isEmpty && !selectedLevels.contains(spell.level) {
                    return false
                }

                if !selectedSchools.isEmpty && !selectedSchools.contains(spell.school) {
                    return false
                }

                if !selectedClasses.isEmpty {
                    let spellClasses = Set(spell.classes)
                    if spellClasses.intersection(selectedClasses).isEmpty {
                        return false
                    }
                }

                if concentrationOnly && !spell.concentration {
                    return false
                }

                if ritualOnly && !spell.ritual {
                    return false
                }

                return true
            }.sorted { $0.name < $1.name }
        }.value

        self.filteredSpells = result
        cacheManager.cacheSpellFilters(filters)
    }
}


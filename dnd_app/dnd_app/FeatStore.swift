import Foundation

@MainActor
final class FeatStore: FilterStore {
    @Published var feats: [Feat] = []
    @Published var filteredFeats: [Feat] = []
    @Published var featFilters = FeatFilters()

    @Published var availableFeatCategories: [String] = []

    override init() {
        super.init()
        loadFeats()
        loadCachedFilters()
    }

    private func loadFeats() {
        Task {
            if let (feats, fromCache) = await loadDecodableArray(
                fileName: "feats",
                cacheGetter: cacheManager.getCachedFeats,
                cacheSetter: cacheManager.cacheFeats
            ) {
                let categories = Set(feats.map { $0.category })
                self.feats = feats
                self.availableFeatCategories = Array(categories).sorted()
                await applyFiltersAsync()
                let message = fromCache
                    ? "✅ [FEATS] Загружено \(feats.count) черт из кэша"
                    : "✅ [FEATS] Загружено \(feats.count) черт из \(categories.count) категорий и закэшировано"
                print(message)
            }
        }
    }

    func updateFeatSearchText(_ text: String) {
        featFilters.searchText = text
        Task { await applyFiltersAsync() }
    }

    func toggleFeatCategoryFilter(_ category: String) {
        featFilters.toggleCategoryFilter(category)
        Task { await applyFiltersAsync() }
    }

    func clearFeatFilters() {
        featFilters.clear()
        Task { await applyFiltersAsync() }
    }

    private func loadCachedFilters() {
        if let cachedFeatFilters = cacheManager.getCachedFeatFilters() {
            featFilters = cachedFeatFilters
            print("✅ [CACHE] Загружены кэшированные фильтры черт")
        }
    }

    private func applyFiltersAsync() async {
        let feats = self.feats
        let filters = self.featFilters

        let result = await Task.detached(priority: .userInitiated) -> [Feat] in
            let searchText = filters.searchText.lowercased()
            let selectedCategories = filters.selectedCategories

            return feats.filter { feat in
                if !searchText.isEmpty {
                    if !feat.name.lowercased().contains(searchText) &&
                       !feat.description.lowercased().contains(searchText) {
                        return false
                    }
                }

                if !selectedCategories.isEmpty && !selectedCategories.contains(feat.category) {
                    return false
                }

                return true
            }.sorted { $0.name < $1.name }
        }.value

        self.filteredFeats = result
        cacheManager.cacheFeatFilters(filters)
    }
}


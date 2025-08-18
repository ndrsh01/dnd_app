import Foundation

@MainActor
final class BackgroundStore: FilterStore {
    @Published var backgrounds: [Background] = []
    @Published var filteredBackgrounds: [Background] = []
    @Published var backgroundFilters = BackgroundFilters()

    override init() {
        super.init()
        loadBackgrounds()
    }

    private func loadBackgrounds() {
        Task {
            if let (backgrounds, fromCache) = await loadDecodableArray(
                fileName: "backgrounds",
                cacheGetter: cacheManager.getCachedBackgrounds,
                cacheSetter: cacheManager.cacheBackgrounds
            ) {
                self.backgrounds = backgrounds
                applyBackgroundFilters()
                let message = fromCache
                    ? "✅ [BACKGROUNDS] Загружено \(backgrounds.count) предысторий из кэша"
                    : "✅ [BACKGROUNDS] Загружено \(backgrounds.count) предысторий из файла и закэшировано"
                print(message)
            }
        }
    }

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
            if !searchText.isEmpty {
                if !background.name.lowercased().contains(searchText) &&
                   !background.description.lowercased().contains(searchText) &&
                   !background.trait.lowercased().contains(searchText) {
                    return false
                }
            }
            return true
        }.sorted { $0.name < $1.name }
    }
}


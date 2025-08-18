import Foundation

@MainActor
class FilterStore: ObservableObject {
    let cacheManager = CacheManager.shared

    /// Asynchronously loads a decodable array either from cache or from a JSON file in the bundle.
    /// - Returns: Tuple containing the loaded array and a flag indicating whether the data came from cache.
    func loadDecodableArray<T: Decodable>(
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

    func clearAllCaches() {
        cacheManager.clearAllCaches()
        print("✅ [CACHE] Все кэши очищены")
    }
}


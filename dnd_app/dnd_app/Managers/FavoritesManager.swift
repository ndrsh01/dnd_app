import Foundation
import Combine

@MainActor
final class FavoritesManager<T: Hashable>: ObservableObject {
    @Published private(set) var favorites: Set<T> = []
    private let storageKey: String

    init(storageKey: String) {
        self.storageKey = storageKey
        load(key: storageKey)
    }

    func isFavorite(_ item: T) -> Bool {
        favorites.contains(item)
    }

    func toggle(_ item: T) {
        if favorites.contains(item) {
            favorites.remove(item)
        } else {
            favorites.insert(item)
        }
        save(key: storageKey)
    }

    func addMultiple(_ items: [T]) {
        favorites.formUnion(items)
        save(key: storageKey)
    }

    func removeMultiple(_ items: [T]) {
        favorites.subtract(items)
        save(key: storageKey)
    }

    func areAllFavorites(_ items: [T]) -> Bool {
        guard !items.isEmpty else { return false }
        return items.allSatisfy { favorites.contains($0) }
    }

    func toggleMultiple(_ items: [T]) {
        if areAllFavorites(items) {
            removeMultiple(items)
        } else {
            addMultiple(items)
        }
    }

    func save(key: String) {
        UserDefaults.standard.set(Array(favorites), forKey: key)
    }

    func load(key: String) {
        if let array = UserDefaults.standard.array(forKey: key) as? [T] {
            favorites = Set(array)
        }
    }
}

@MainActor
final class Favorites: ObservableObject {
    let spells = FavoritesManager<String>(storageKey: "favoriteSpells")
    let feats = FavoritesManager<String>(storageKey: "favoriteFeats")
    let backgrounds = FavoritesManager<String>(storageKey: "favoriteBackgrounds")

    private var cancellables: Set<AnyCancellable> = []

    init() {
        spells.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)

        feats.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)

        backgrounds.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
}


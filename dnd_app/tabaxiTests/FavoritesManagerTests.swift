import XCTest
@testable import tabaxi

@MainActor
final class FavoritesManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "favoriteSpells")
        defaults.removeObject(forKey: "favoriteFeats")
        defaults.removeObject(forKey: "favoriteBackgrounds")
        CacheManager.shared.clearAllCaches()
    }

    override func tearDown() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "favoriteSpells")
        defaults.removeObject(forKey: "favoriteFeats")
        defaults.removeObject(forKey: "favoriteBackgrounds")
        CacheManager.shared.clearAllCaches()
        super.tearDown()
    }

    func testToggleFavoriteSpell() {
        let manager = FavoriteSpellsManager()
        manager.toggleSpell("Fireball")
        XCTAssertTrue(manager.isSpellFavorite("Fireball"))
        manager.toggleSpell("Fireball")
        XCTAssertFalse(manager.isSpellFavorite("Fireball"))
    }

    func testPersistenceWithUserDefaults() {
        var manager: FavoriteSpellsManager? = FavoriteSpellsManager()
        manager?.toggleSpell("Magic Missile")
        XCTAssertTrue(manager?.isSpellFavorite("Magic Missile") ?? false)
        manager = nil
        CacheManager.shared.clearAllCaches()
        let newManager = FavoriteSpellsManager()
        XCTAssertTrue(newManager.isSpellFavorite("Magic Missile"))
    }
}

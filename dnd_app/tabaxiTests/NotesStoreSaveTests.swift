import XCTest
@testable import tabaxi

final class NotesStoreSaveTests: XCTestCase {
    func testSaveOccursAfterDelay() {
        UserDefaults.standard.removeObject(forKey: "notes_v1")
        CacheManager.shared.clearCache(for: CacheManager.CacheKey.notes.rawValue)
        let store = NotesStore()
        let note = Note(title: "title", description: "", category: .places, importance: 1, dateCreated: Date(), dateModified: Date())
        store.add(note)
        XCTAssertEqual(store.saveCallCount, 0)
        let exp = expectation(description: "wait for save")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(store.saveCallCount, 1)
    }

    func testFrequentEditsTriggerSingleSave() {
        UserDefaults.standard.removeObject(forKey: "notes_v1")
        CacheManager.shared.clearCache(for: CacheManager.CacheKey.notes.rawValue)
        let store = NotesStore()
        var note = Note(title: "title", description: "", category: .places, importance: 1, dateCreated: Date(), dateModified: Date())
        store.add(note)
        note.title = "updated 1"
        store.update(note)
        note.title = "updated 2"
        store.update(note)
        let exp = expectation(description: "wait for save")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(store.saveCallCount, 1)
        XCTAssertEqual(store.notes.first?.title, "updated 2")
    }
}

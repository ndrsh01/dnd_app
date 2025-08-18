import XCTest
@testable import tabaxi

final class CacheManagerTests: XCTestCase {
    struct MockCodable: Codable, Equatable {
        let id: Int
        let name: String
    }

    override func setUp() {
        super.setUp()
        CacheManager.shared.clearAllCaches()
    }

    func testCodableSerializationAndDeserialization() {
        let cache = CacheManager.shared
        let key = "test_codables"
        let object = MockCodable(id: 1, name: "Test")
        cache.cacheCodable(object, for: key)
        let retrieved: MockCodable? = cache.getCodable(for: key)
        XCTAssertEqual(retrieved, object)
    }

    func testCacheExpiration() {
        let cache = CacheManager.shared
        let key = "test_cache_expiration"
        let data = "temp".data(using: .utf8)!
        cache.cacheData(data, for: key, expiration: 1)
        XCTAssertNotNil(cache.getData(for: key))

        let expectation = XCTestExpectation(description: "Data expired")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertNil(cache.getData(for: key))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

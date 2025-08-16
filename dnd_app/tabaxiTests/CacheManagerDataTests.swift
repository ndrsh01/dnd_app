import XCTest
@testable import tabaxi

final class CacheManagerDataTests: XCTestCase {
    func testCacheDataRetrieval() {
        let cache = CacheManager.shared
        let key = "test_cache_data_retrieval"
        let originalData = "hello world".data(using: .utf8)!
        cache.cacheData(originalData, for: key)
        let retrieved = cache.getData(for: key)
        XCTAssertEqual(retrieved, originalData)
    }
}

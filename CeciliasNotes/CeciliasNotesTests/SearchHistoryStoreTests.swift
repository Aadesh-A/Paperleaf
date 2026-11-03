import XCTest
@testable import CeciliasNotes

final class SearchHistoryStoreTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "SearchHistoryStoreTests")
        defaults.removePersistentDomain(forName: "SearchHistoryStoreTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "SearchHistoryStoreTests")
        defaults = nil
        super.tearDown()
    }

    func testRecordDeduplicatesCaseInsensitivelyAndMovesTermToFront() {
        SearchHistoryStore.record("Biology", in: defaults)
        SearchHistoryStore.record("calculus", in: defaults)
        SearchHistoryStore.record("biology", in: defaults)

        XCTAssertEqual(SearchHistoryStore.recent(in: defaults), ["biology", "calculus"])
    }

    func testRecordTrimsAndCapsHistory() {
        for index in 0..<(SearchHistoryStore.maximumCount + 3) {
            SearchHistoryStore.record(" topic \(index) ", in: defaults)
        }

        let recent = SearchHistoryStore.recent(in: defaults)
        XCTAssertEqual(recent.count, SearchHistoryStore.maximumCount)
        XCTAssertEqual(recent.first, "topic \(SearchHistoryStore.maximumCount + 2)")
    }
}

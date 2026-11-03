import Foundation

/// Small, local-only history for the library search field. Search terms are
/// deliberately kept out of CloudKit: they are navigation affordances, not
/// notebook content, and should stay private to the device that entered them.
enum SearchHistoryStore {
    static let maximumCount = 8
    private static let storageKey = "paperleaf.search.recent.v1"

    static func recent(in defaults: UserDefaults = .standard) -> [String] {
        defaults.stringArray(forKey: storageKey) ?? []
    }

    @discardableResult
    static func record(_ query: String, in defaults: UserDefaults = .standard) -> [String] {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count >= 2 else { return recent(in: defaults) }

        var searches = recent(in: defaults)
        searches.removeAll { $0.localizedCaseInsensitiveCompare(cleaned) == .orderedSame }
        searches.insert(cleaned, at: 0)
        searches = Array(searches.prefix(maximumCount))
        defaults.set(searches, forKey: storageKey)
        return searches
    }

    static func clear(in defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: storageKey)
    }
}

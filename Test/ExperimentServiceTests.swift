import XCTest
@testable import ThriftFeedCore

final class ExperimentServiceTests: XCTestCase {
    private let service = HashedExperimentService()

    func testSameUserAlwaysGetsSameVariant() {
        let first = service.priceDisplayVariant(forUserID: "user-1")
        for _ in 0..<100 {
            XCTAssertEqual(service.priceDisplayVariant(forUserID: "user-1"), first)
        }
    }

    /// Pinned values: if these change, every real user would be moved to a different variant,
    /// which would corrupt a running experiment. A failure here means the hashing was changed.
    func testKnownUsersLandInExpectedBuckets() {
        XCTAssertEqual(service.priceDisplayVariant(forUserID: "user-1"), .itemPrice)
        XCTAssertEqual(service.priceDisplayVariant(forUserID: "user-3"), .totalWithProtection)
    }

    func testSplitIsRoughlyFiftyFifty() {
        let total = 20_000
        var controlCount = 0
        for index in 0..<total where service.priceDisplayVariant(forUserID: "user-\(index)") == .itemPrice {
            controlCount += 1
        }
        let share = Double(controlCount) / Double(total)
        XCTAssertGreaterThan(share, 0.47)
        XCTAssertLessThan(share, 0.53)
    }
}

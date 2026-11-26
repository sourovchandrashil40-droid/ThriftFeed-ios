import Foundation

/// Clean Swift "Worker": does the data work so the Interactor stays focused on business rules.
/// Swap the implementation to talk to a real API without touching the Interactor.
public protocol ListingsWorker: Sendable {
    func fetchListings() async throws -> [Listing]
}

public enum ListingsWorkerError: Error, Equatable {
    case unavailable
}

/// Offline implementation with fake latency and an optional forced failure, used by the demo app and tests.
public struct InMemoryListingsWorker: ListingsWorker {
    private let listings: [Listing]
    private let delayNanoseconds: UInt64
    private let shouldFail: Bool

    public init(
        listings: [Listing] = Listing.samples,
        delayNanoseconds: UInt64 = 0,
        shouldFail: Bool = false
    ) {
        self.listings = listings
        self.delayNanoseconds = delayNanoseconds
        self.shouldFail = shouldFail
    }

    public func fetchListings() async throws -> [Listing] {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        if shouldFail {
            throw ListingsWorkerError.unavailable
        }
        return listings
    }
}

import Foundation

/// The two ways the feed can show a price. This is the thing the A/B test compares.
public enum PriceDisplayVariant: String, Equatable, Sendable {
    /// Control: show only the item price.
    case itemPrice
    /// Treatment: also show the total including the buyer fee.
    case totalWithProtection
}

public protocol ExperimentService: Sendable {
    func priceDisplayVariant(forUserID userID: String) -> PriceDisplayVariant
}

/// Assigns users to a variant by hashing their id, so a user always sees the same variant
/// without any server call or stored state.
///
/// Swift's built-in `hashValue` is randomly seeded on every app launch, so it must NOT be used
/// for bucketing. FNV-1a is a tiny, stable hash that gives the same result forever.
public struct HashedExperimentService: ExperimentService {
    /// Changing the salt re-shuffles users, so each experiment gets its own salt.
    static let salt = ":price_display_v1"
    static let treatmentStartsAtBucket = 50

    public init() {}

    public func priceDisplayVariant(forUserID userID: String) -> PriceDisplayVariant {
        let bucket = Int(StableHash.fnv1a(userID + Self.salt) % 100)
        return bucket < Self.treatmentStartsAtBucket ? .itemPrice : .totalWithProtection
    }
}

enum StableHash {
    /// 64-bit FNV-1a over the UTF-8 bytes of the string.
    static func fnv1a(_ text: String) -> UInt64 {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return hash
    }
}

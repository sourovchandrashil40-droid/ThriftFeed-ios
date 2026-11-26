import Foundation

/// A second-hand item for sale.
/// Prices are stored as integer cents to avoid floating-point rounding errors.
public struct Listing: Equatable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let brand: String
    public let size: String
    public let priceCents: Int
    public let sellerName: String

    public init(
        id: Int,
        title: String,
        brand: String,
        size: String,
        priceCents: Int,
        sellerName: String
    ) {
        self.id = id
        self.title = title
        self.brand = brand
        self.size = size
        self.priceCents = priceCents
        self.sellerName = sellerName
    }
}

public extension Listing {
    /// Demo data used by the in-memory worker and by previews.
    static let samples: [Listing] = [
        Listing(id: 1, title: "Vintage denim jacket", brand: "Levi's", size: "M", priceCents: 2800, sellerName: "Ona"),
        Listing(id: 2, title: "Running shoes", brand: "Nike", size: "42", priceCents: 3500, sellerName: "Tomas"),
        Listing(id: 3, title: "Wool winter coat", brand: "Zara", size: "L", priceCents: 4500, sellerName: "Greta"),
        Listing(id: 4, title: "Cotton t-shirt", brand: "H&M", size: "S", priceCents: 400, sellerName: "Jonas"),
        Listing(id: 5, title: "Leather backpack", brand: "Fjallraven", size: "One size", priceCents: 6000, sellerName: "Rasa"),
        Listing(id: 6, title: "Slim fit jeans", brand: "Levi's", size: "32", priceCents: 1900, sellerName: "Mantas"),
        Listing(id: 7, title: "Rain jacket", brand: "Columbia", size: "M", priceCents: 3200, sellerName: "Ieva"),
        Listing(id: 8, title: "Canvas sneakers", brand: "Converse", size: "40", priceCents: 1500, sellerName: "Lukas")
    ]
}

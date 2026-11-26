import Foundation

/// Clean Swift request / response / view-model types for the Feed scene.
///
///   ViewController --Request--> Interactor --Response--> Presenter --ViewModel--> ViewController
public enum Feed {
    public enum SortOrder: Equatable, Sendable {
        case relevance
        case priceLowToHigh
    }

    // MARK: Requests (View -> Interactor)

    public enum Load {
        public struct Request {
            public init() {}
        }
    }

    public enum Search {
        public struct Request {
            public let query: String
            public init(query: String) { self.query = query }
        }
    }

    public enum ToggleFavorite {
        public struct Request {
            public let listingID: Int
            public init(listingID: Int) { self.listingID = listingID }
        }
    }

    public enum ToggleSort {
        public struct Request {
            public init() {}
        }
    }

    public enum SelectListing {
        public struct Request {
            public let listingID: Int
            public init(listingID: Int) { self.listingID = listingID }
        }
    }

    // MARK: Response / ViewModel (Interactor -> Presenter -> View)

    public enum Present {
        public struct Response {
            public let listings: [Listing]
            public let favoriteIDs: Set<Int>
            public let variant: PriceDisplayVariant
            public let sortOrder: SortOrder

            public init(
                listings: [Listing],
                favoriteIDs: Set<Int>,
                variant: PriceDisplayVariant,
                sortOrder: SortOrder
            ) {
                self.listings = listings
                self.favoriteIDs = favoriteIDs
                self.variant = variant
                self.sortOrder = sortOrder
            }
        }

        public struct ViewModel: Equatable {
            public let rows: [Row]
            public let headerText: String
            public let emptyMessage: String?
            public let sortTitle: String

            public init(rows: [Row], headerText: String, emptyMessage: String?, sortTitle: String) {
                self.rows = rows
                self.headerText = headerText
                self.emptyMessage = emptyMessage
                self.sortTitle = sortTitle
            }
        }
    }

    public enum Failure {
        public struct Response {
            public let message: String
            public init(message: String) { self.message = message }
        }

        public struct ViewModel: Equatable {
            public let message: String
            public init(message: String) { self.message = message }
        }
    }

    /// Everything a table row needs, already formatted as strings. The view does no formatting.
    public struct Row: Equatable {
        public let id: Int
        public let title: String
        public let subtitle: String
        public let priceText: String
        public let secondaryPriceText: String?
        public let isFavorite: Bool
        public let favoriteAccessibilityLabel: String

        public init(
            id: Int,
            title: String,
            subtitle: String,
            priceText: String,
            secondaryPriceText: String?,
            isFavorite: Bool,
            favoriteAccessibilityLabel: String
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.priceText = priceText
            self.secondaryPriceText = secondaryPriceText
            self.isFavorite = isFavorite
            self.favoriteAccessibilityLabel = favoriteAccessibilityLabel
        }
    }
}

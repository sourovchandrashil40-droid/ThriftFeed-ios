import Foundation

/// What the Interactor may tell the Presenter.
@MainActor
public protocol FeedPresentationLogic: AnyObject {
    func presentFeed(response: Feed.Present.Response)
    func presentFailure(response: Feed.Failure.Response)
}

/// What the Presenter may tell the View. The View only displays; it makes no decisions.
@MainActor
public protocol FeedDisplayLogic: AnyObject {
    func displayFeed(viewModel: Feed.Present.ViewModel)
    func displayFailure(viewModel: Feed.Failure.ViewModel)
}

/// Turns business data into display-ready strings.
@MainActor
public final class FeedPresenter: FeedPresentationLogic {
    public weak var viewController: FeedDisplayLogic?

    public init() {}

    public func presentFeed(response: Feed.Present.Response) {
        let rows = response.listings.map { listing in
            makeRow(listing, isFavorite: response.favoriteIDs.contains(listing.id), variant: response.variant)
        }

        let count = rows.count
        let viewModel = Feed.Present.ViewModel(
            rows: rows,
            headerText: count == 1 ? "1 item" : "\(count) items",
            emptyMessage: rows.isEmpty ? "No items match your search." : nil,
            sortTitle: response.sortOrder == .relevance ? "Sort: Relevance" : "Sort: Price, low to high"
        )
        viewController?.displayFeed(viewModel: viewModel)
    }

    public func presentFailure(response: Feed.Failure.Response) {
        viewController?.displayFailure(viewModel: Feed.Failure.ViewModel(message: response.message))
    }

    private func makeRow(_ listing: Listing, isFavorite: Bool, variant: PriceDisplayVariant) -> Feed.Row {
        let secondaryPriceText: String?
        switch variant {
        case .itemPrice:
            secondaryPriceText = nil
        case .totalWithProtection:
            let total = PricingCalculator.totalCents(forItemPriceCents: listing.priceCents)
            secondaryPriceText = "\(MoneyFormatter.euros(cents: total)) incl. Buyer Protection"
        }

        return Feed.Row(
            id: listing.id,
            title: listing.title,
            subtitle: "\(listing.brand) · \(listing.size)",
            priceText: MoneyFormatter.euros(cents: listing.priceCents),
            secondaryPriceText: secondaryPriceText,
            isFavorite: isFavorite,
            favoriteAccessibilityLabel: isFavorite
                ? "Remove \(listing.title) from favourites"
                : "Add \(listing.title) to favourites"
        )
    }
}

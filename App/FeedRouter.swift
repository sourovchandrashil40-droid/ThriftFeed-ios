import UIKit
import ThriftFeedCore

/// Decides where to go next and passes data to the next scene.
@MainActor
final class FeedRouter {
    weak var viewController: UIViewController?
    weak var dataStore: FeedDataStore?

    func routeToListingDetail() {
        guard let listing = dataStore?.selectedListing else { return }
        let detail = ListingDetailViewController(listing: listing)
        viewController?.navigationController?.pushViewController(detail, animated: true)
    }
}

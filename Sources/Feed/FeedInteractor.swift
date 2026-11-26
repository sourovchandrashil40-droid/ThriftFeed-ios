import Foundation

/// What the View may ask the Interactor to do.
@MainActor
public protocol FeedBusinessLogic: AnyObject {
    func loadFeed(request: Feed.Load.Request) async
    func search(request: Feed.Search.Request)
    func toggleFavorite(request: Feed.ToggleFavorite.Request)
    func toggleSort(request: Feed.ToggleSort.Request)
    func selectListing(request: Feed.SelectListing.Request)
}

/// Data the Router is allowed to read when it navigates to the next scene.
@MainActor
public protocol FeedDataStore: AnyObject {
    var selectedListing: Listing? { get }
}

/// Business rules for the feed: searching, sorting, favourites and experiment assignment.
/// It never touches UIKit and never formats strings; that is the Presenter's job.
@MainActor
public final class FeedInteractor: FeedBusinessLogic, FeedDataStore {
    public var presenter: FeedPresentationLogic?
    public private(set) var selectedListing: Listing?

    private let worker: ListingsWorker
    private let experiments: ExperimentService
    private let userID: String

    private var allListings: [Listing] = []
    private var favoriteIDs: Set<Int> = []
    private var query = ""
    private var sortOrder: Feed.SortOrder = .relevance

    public init(worker: ListingsWorker, experiments: ExperimentService, userID: String) {
        self.worker = worker
        self.experiments = experiments
        self.userID = userID
    }

    public func loadFeed(request: Feed.Load.Request) async {
        do {
            allListings = try await worker.fetchListings()
            presentCurrentState()
        } catch {
            presenter?.presentFailure(
                response: Feed.Failure.Response(message: "Could not load items. Please try again.")
            )
        }
    }

    public func search(request: Feed.Search.Request) {
        query = request.query
        presentCurrentState()
    }

    public func toggleFavorite(request: Feed.ToggleFavorite.Request) {
        if favoriteIDs.contains(request.listingID) {
            favoriteIDs.remove(request.listingID)
        } else {
            favoriteIDs.insert(request.listingID)
        }
        presentCurrentState()
    }

    public func toggleSort(request: Feed.ToggleSort.Request) {
        sortOrder = (sortOrder == .relevance) ? .priceLowToHigh : .relevance
        presentCurrentState()
    }

    public func selectListing(request: Feed.SelectListing.Request) {
        selectedListing = allListings.first { $0.id == request.listingID }
    }

    // MARK: Private

    private func presentCurrentState() {
        let response = Feed.Present.Response(
            listings: visibleListings(),
            favoriteIDs: favoriteIDs,
            variant: experiments.priceDisplayVariant(forUserID: userID),
            sortOrder: sortOrder
        )
        presenter?.presentFeed(response: response)
    }

    private func visibleListings() -> [Listing] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var result = allListings

        if !trimmedQuery.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(trimmedQuery)
                    || $0.brand.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }

        if sortOrder == .priceLowToHigh {
            result.sort { lhs, rhs in
                if lhs.priceCents != rhs.priceCents {
                    return lhs.priceCents < rhs.priceCents
                }
                return lhs.id < rhs.id // tie-break so the order is always the same
            }
        }

        return result
    }
}

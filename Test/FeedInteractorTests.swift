import XCTest
@testable import ThriftFeedCore

@MainActor
final class FeedInteractorTests: XCTestCase {
    private func makeSUT(
        shouldFail: Bool = false,
        variant: PriceDisplayVariant = .itemPrice
    ) -> (sut: FeedInteractor, presenter: PresenterSpy) {
        let presenter = PresenterSpy()
        let sut = FeedInteractor(
            worker: InMemoryListingsWorker(shouldFail: shouldFail),
            experiments: FixedExperimentService(variant: variant),
            userID: "test-user"
        )
        sut.presenter = presenter
        return (sut, presenter)
    }

    func testLoadPresentsAllListings() async {
        let (sut, presenter) = makeSUT()

        await sut.loadFeed(request: Feed.Load.Request())

        XCTAssertEqual(presenter.lastResponse?.listings, Listing.samples)
        XCTAssertEqual(presenter.lastResponse?.sortOrder, .relevance)
    }

    func testLoadFailurePresentsErrorAndNoFeed() async {
        let (sut, presenter) = makeSUT(shouldFail: true)

        await sut.loadFeed(request: Feed.Load.Request())

        XCTAssertEqual(presenter.failures.count, 1)
        XCTAssertTrue(presenter.responses.isEmpty)
    }

    func testResponseCarriesExperimentVariant() async {
        let (sut, presenter) = makeSUT(variant: .totalWithProtection)

        await sut.loadFeed(request: Feed.Load.Request())

        XCTAssertEqual(presenter.lastResponse?.variant, .totalWithProtection)
    }

    func testSearchMatchesTitleCaseInsensitively() async {
        let (sut, presenter) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())

        sut.search(request: Feed.Search.Request(query: "JACKET"))

        let titles = presenter.lastResponse?.listings.map(\.title)
        XCTAssertEqual(titles, ["Vintage denim jacket", "Rain jacket"])
    }

    func testSearchMatchesBrand() async {
        let (sut, presenter) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())

        sut.search(request: Feed.Search.Request(query: "levi"))

        XCTAssertEqual(presenter.lastResponse?.listings.map(\.id), [1, 6])
    }

    func testBlankSearchShowsEverything() async {
        let (sut, presenter) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())

        sut.search(request: Feed.Search.Request(query: "   "))

        XCTAssertEqual(presenter.lastResponse?.listings.count, Listing.samples.count)
    }

    func testSearchWithNoMatchesPresentsEmptyList() async {
        let (sut, presenter) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())

        sut.search(request: Feed.Search.Request(query: "spaceship"))

        XCTAssertEqual(presenter.lastResponse?.listings, [])
    }

    func testToggleSortOrdersByPriceAscending() async {
        let (sut, presenter) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())

        sut.toggleSort(request: Feed.ToggleSort.Request())

        let prices = presenter.lastResponse?.listings.map(\.priceCents) ?? []
        XCTAssertEqual(prices, prices.sorted())
        XCTAssertEqual(presenter.lastResponse?.sortOrder, .priceLowToHigh)
    }

    func testToggleSortTwiceReturnsToOriginalOrder() async {
        let (sut, presenter) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())

        sut.toggleSort(request: Feed.ToggleSort.Request())
        sut.toggleSort(request: Feed.ToggleSort.Request())

        XCTAssertEqual(presenter.lastResponse?.listings, Listing.samples)
        XCTAssertEqual(presenter.lastResponse?.sortOrder, .relevance)
    }

    func testToggleFavoriteAddsThenRemoves() async {
        let (sut, presenter) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())

        sut.toggleFavorite(request: Feed.ToggleFavorite.Request(listingID: 3))
        XCTAssertEqual(presenter.lastResponse?.favoriteIDs, [3])

        sut.toggleFavorite(request: Feed.ToggleFavorite.Request(listingID: 3))
        XCTAssertEqual(presenter.lastResponse?.favoriteIDs, [])
    }

    func testFavoritesSurviveSearching() async {
        let (sut, presenter) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())
        sut.toggleFavorite(request: Feed.ToggleFavorite.Request(listingID: 2))

        sut.search(request: Feed.Search.Request(query: "jeans"))

        XCTAssertEqual(presenter.lastResponse?.favoriteIDs, [2])
    }

    func testSelectListingStoresItForTheRouter() async {
        let (sut, _) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())

        sut.selectListing(request: Feed.SelectListing.Request(listingID: 5))

        XCTAssertEqual(sut.selectedListing?.id, 5)
    }

    func testSelectingUnknownListingClearsSelection() async {
        let (sut, _) = makeSUT()
        await sut.loadFeed(request: Feed.Load.Request())
        sut.selectListing(request: Feed.SelectListing.Request(listingID: 5))

        sut.selectListing(request: Feed.SelectListing.Request(listingID: 999))

        XCTAssertNil(sut.selectedListing)
    }
}

import XCTest
@testable import ThriftFeedCore

@MainActor
final class FeedPresenterTests: XCTestCase {
    private let jacket = Listing(
        id: 1, title: "Denim jacket", brand: "Levi's", size: "M", priceCents: 1000, sellerName: "Ona"
    )

    private func makeSUT() -> (sut: FeedPresenter, display: DisplaySpy) {
        let display = DisplaySpy()
        let sut = FeedPresenter()
        sut.viewController = display
        return (sut, display)
    }

    private func response(
        _ listings: [Listing],
        favorites: Set<Int> = [],
        variant: PriceDisplayVariant = .itemPrice,
        sortOrder: Feed.SortOrder = .relevance
    ) -> Feed.Present.Response {
        Feed.Present.Response(listings: listings, favoriteIDs: favorites, variant: variant, sortOrder: sortOrder)
    }

    func testControlVariantShowsOnlyItemPrice() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([jacket], variant: .itemPrice))

        let row = display.lastViewModel?.rows.first
        XCTAssertEqual(row?.priceText, "€10.00")
        XCTAssertNil(row?.secondaryPriceText)
    }

    func testTreatmentVariantShowsTotalIncludingFee() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([jacket], variant: .totalWithProtection))

        let row = display.lastViewModel?.rows.first
        XCTAssertEqual(row?.priceText, "€10.00")
        XCTAssertEqual(row?.secondaryPriceText, "€11.20 incl. Buyer Protection")
    }

    func testRowSubtitleCombinesBrandAndSize() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([jacket]))

        XCTAssertEqual(display.lastViewModel?.rows.first?.subtitle, "Levi's · M")
    }

    func testFavoriteStateAndAccessibilityLabel() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([jacket], favorites: [1]))

        let row = display.lastViewModel?.rows.first
        XCTAssertEqual(row?.isFavorite, true)
        XCTAssertEqual(row?.favoriteAccessibilityLabel, "Remove Denim jacket from favourites")
    }

    func testNotFavoriteAccessibilityLabel() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([jacket]))

        XCTAssertEqual(
            display.lastViewModel?.rows.first?.favoriteAccessibilityLabel,
            "Add Denim jacket to favourites"
        )
    }

    func testHeaderUsesSingularAndPlural() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([jacket]))
        XCTAssertEqual(display.lastViewModel?.headerText, "1 item")

        sut.presentFeed(response: response(Listing.samples))
        XCTAssertEqual(display.lastViewModel?.headerText, "\(Listing.samples.count) items")
    }

    func testEmptyListShowsMessage() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([]))

        XCTAssertEqual(display.lastViewModel?.emptyMessage, "No items match your search.")
        XCTAssertEqual(display.lastViewModel?.headerText, "0 items")
    }

    func testNonEmptyListHasNoEmptyMessage() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([jacket]))

        XCTAssertNil(display.lastViewModel?.emptyMessage)
    }

    func testSortTitleFollowsSortOrder() {
        let (sut, display) = makeSUT()

        sut.presentFeed(response: response([jacket], sortOrder: .relevance))
        XCTAssertEqual(display.lastViewModel?.sortTitle, "Sort: Relevance")

        sut.presentFeed(response: response([jacket], sortOrder: .priceLowToHigh))
        XCTAssertEqual(display.lastViewModel?.sortTitle, "Sort: Price, low to high")
    }

    func testFailureIsForwardedToView() {
        let (sut, display) = makeSUT()

        sut.presentFailure(response: Feed.Failure.Response(message: "Oops"))

        XCTAssertEqual(display.failures, [Feed.Failure.ViewModel(message: "Oops")])
    }
}

import Foundation
@testable import ThriftFeedCore

/// Records what the Interactor tells the Presenter.
@MainActor
final class PresenterSpy: FeedPresentationLogic {
    private(set) var responses: [Feed.Present.Response] = []
    private(set) var failures: [Feed.Failure.Response] = []

    var lastResponse: Feed.Present.Response? { responses.last }

    func presentFeed(response: Feed.Present.Response) {
        responses.append(response)
    }

    func presentFailure(response: Feed.Failure.Response) {
        failures.append(response)
    }
}

/// Records what the Presenter tells the View.
@MainActor
final class DisplaySpy: FeedDisplayLogic {
    private(set) var viewModels: [Feed.Present.ViewModel] = []
    private(set) var failures: [Feed.Failure.ViewModel] = []

    var lastViewModel: Feed.Present.ViewModel? { viewModels.last }

    func displayFeed(viewModel: Feed.Present.ViewModel) {
        viewModels.append(viewModel)
    }

    func displayFailure(viewModel: Feed.Failure.ViewModel) {
        failures.append(viewModel)
    }
}

/// Always returns the same variant so tests do not depend on hashing.
struct FixedExperimentService: ExperimentService {
    let variant: PriceDisplayVariant

    func priceDisplayVariant(forUserID userID: String) -> PriceDisplayVariant {
        variant
    }
}

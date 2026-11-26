import UIKit
import ThriftFeedCore

/// Wires the Clean Swift scene together in one place:
///
///   ViewController -> Interactor -> Presenter -> ViewController (weak)
///   ViewController -> Router -> reads Interactor's data store
@MainActor
enum FeedConfigurator {
    /// A fixed demo user, so the experiment variant is the same on every launch.
    /// Change this string to see the other variant of the price experiment.
    static let demoUserID = "demo-user-42"

    static func makeViewController() -> FeedViewController {
        let viewController = FeedViewController()
        let interactor = FeedInteractor(
            worker: InMemoryListingsWorker(delayNanoseconds: 600_000_000),
            experiments: HashedExperimentService(),
            userID: demoUserID
        )
        let presenter = FeedPresenter()
        let router = FeedRouter()

        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor

        return viewController
    }
}

import UIKit

@main
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let feed = FeedConfigurator.makeViewController()
        window.rootViewController = UINavigationController(rootViewController: feed)
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

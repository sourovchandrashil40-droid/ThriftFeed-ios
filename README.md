# ThriftFeed

A small iOS app that shows a second-hand marketplace feed: browse items, search, sort by price, mark favourites and open an item.
It is a learning project built to practise the engineering style used on large Swift codebases:
**Clean Swift (VIP)**, unit-tested business logic, and **experiment-driven product changes**.

> Demo data only. Prices, sellers and the "Buyer Protection" fee are made up and are not from any real marketplace.

## What it demonstrates

| Topic | Where to look |
|---|---|
| Clean Swift scene (View, Interactor, Presenter, Worker, Router, Configurator) | `Sources/ThriftFeedCore/Feed`, `App/` |
| Business logic with no UIKit, fully unit-tested | `Sources/ThriftFeedCore`, `Tests/` |
| A/B experiment with stable user bucketing | `Experiments/ExperimentService.swift` |
| Money as integer cents, deterministic formatting | `Models/Money.swift` |
| Swift concurrency (`async`/`await`, `@MainActor`) | `FeedInteractor`, `ListingsWorker` |
| Programmatic UIKit, Dynamic Type, VoiceOver labels | `FeedViewController`, `ListingCell` |
| CI on every push and pull request | `.github/workflows/ci.yml` |

## Architecture

```
FeedViewController --Request--> FeedInteractor --Response--> FeedPresenter --ViewModel--> FeedViewController
                                     |   ^
                                     v   |
                               ListingsWorker (data)
FeedViewController --> FeedRouter --reads--> FeedInteractor (FeedDataStore)
```

- **Interactor** owns the rules: search (title or brand, case-insensitive), sort (price, with a tie-break so order is stable), favourites, and which experiment variant the user gets. It never imports UIKit and never builds strings.
- **Presenter** turns business data into display-ready strings (`€12.50`, `Levi's · M`, `1 item` vs `3 items`).
- **View** only renders view models and forwards taps. No decisions.
- **Worker** hides where data comes from. `InMemoryListingsWorker` is used here; a real API client could replace it without touching the Interactor.
- **Router** navigates and passes the selected item through the Interactor's data store.

The core (everything except UIKit views) lives in a Swift package, `ThriftFeedCore`, so tests run in seconds with `swift test`.

## The experiment

Users are split 50/50 by hashing their id (FNV-1a, 64-bit):

- **Control** (`itemPrice`): shows `€10.00`.
- **Treatment** (`totalWithProtection`): shows `€10.00` plus `€11.20 incl. Buyer Protection`.

Why not Swift's `hashValue`? It is randomly seeded on every launch, so a user would flip between variants. A stable hash keeps each user in one group, which an A/B test requires. A unit test pins two known users to their buckets so nobody can change the hashing by accident, and another test checks the split stays close to 50/50.

Change `demoUserID` in `App/FeedConfigurator.swift` to see the other variant.

## Run it

**Tests (no Xcode project needed):**

```bash
swift test
```

**The app:**

```bash
brew install xcodegen
xcodegen generate
open ThriftFeed.xcodeproj
```

Then pick an iPhone simulator and press Run. Requires Xcode 15+ and iOS 16+.

If you prefer not to use XcodeGen: create a new iOS App in Xcode (Interface: Storyboard, Language: Swift), delete its generated `ViewController.swift`, `Main.storyboard`, `SceneDelegate.swift`, and `AppDelegate.swift`, drag the files from `App/` in, add this folder as a local Swift package dependency, and remove the Main storyboard and scene manifest entries from Info.plist.

## Tests

Unit tests cover the Interactor (loading, failure, search, sort, favourites, selection), the Presenter (formatting, both experiment variants, empty state), pricing, money formatting and experiment bucketing. The Interactor and Presenter are tested through small spies, so no UI is involved.

## Possible next steps

- Replace `InMemoryListingsWorker` with a `URLSession` worker and decode JSON.
- Log an exposure event when a user first sees a variant, so the experiment can be analysed.
- Add image loading and caching to the cells.
- Add snapshot or UI tests for the table.
- Add pagination to the feed.

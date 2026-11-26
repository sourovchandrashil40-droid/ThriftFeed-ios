import UIKit
import ThriftFeedCore

/// Displays the feed. It sends requests to the Interactor and renders view models; it contains no business logic.
@MainActor
final class FeedViewController: UIViewController, FeedDisplayLogic {
    var interactor: FeedBusinessLogic?
    var router: FeedRouter?

    private var rows: [Feed.Row] = []

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let headerLabel = UILabel()
    private let emptyLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let searchController = UISearchController(searchResultsController: nil)
    private let sortButton = UIBarButtonItem(title: "Sort", style: .plain, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feed"
        view.backgroundColor = .systemBackground
        setUpNavigation()
        setUpTableView()
        setUpEmptyLabel()
        setUpSpinner()
        loadFeed()
    }

    // MARK: FeedDisplayLogic

    func displayFeed(viewModel: Feed.Present.ViewModel) {
        spinner.stopAnimating()
        rows = viewModel.rows
        headerLabel.text = viewModel.headerText
        sortButton.title = viewModel.sortTitle
        emptyLabel.text = viewModel.emptyMessage
        emptyLabel.isHidden = viewModel.emptyMessage == nil
        tableView.reloadData()
    }

    func displayFailure(viewModel: Feed.Failure.ViewModel) {
        spinner.stopAnimating()
        let alert = UIAlertController(title: "Something went wrong", message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadFeed()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: Actions

    private func loadFeed() {
        spinner.startAnimating()
        Task {
            await interactor?.loadFeed(request: Feed.Load.Request())
        }
    }

    @objc private func sortTapped() {
        interactor?.toggleSort(request: Feed.ToggleSort.Request())
    }

    // MARK: Set-up

    private func setUpNavigation() {
        sortButton.target = self
        sortButton.action = #selector(sortTapped)
        navigationItem.rightBarButtonItem = sortButton

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search items or brands"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setUpTableView() {
        headerLabel.font = .preferredFont(forTextStyle: .footnote)
        headerLabel.textColor = .secondaryLabel
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.accessibilityTraits = .header

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 32
        tableView.register(ListingCell.self, forCellReuseIdentifier: ListingCell.reuseIdentifier)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpEmptyLabel() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.font = .preferredFont(forTextStyle: .body)
        emptyLabel.adjustsFontForContentSizeCategory = true
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    private func setUpSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UISearchResultsUpdating

extension FeedViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        interactor?.search(request: Feed.Search.Request(query: query))
    }
}

// MARK: - UITableViewDataSource / Delegate

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListingCell.reuseIdentifier,
            for: indexPath
        ) as? ListingCell else {
            return UITableViewCell()
        }

        let row = rows[indexPath.row]
        cell.configure(with: row)
        cell.onFavoriteTapped = { [weak self] in
            self?.interactor?.toggleFavorite(request: Feed.ToggleFavorite.Request(listingID: row.id))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            headerLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            headerLabel.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor)
        ])
        return container
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        interactor?.selectListing(request: Feed.SelectListing.Request(listingID: row.id))
        router?.routeToListingDetail()
    }
}

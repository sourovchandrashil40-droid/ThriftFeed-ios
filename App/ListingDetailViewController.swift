import UIKit
import ThriftFeedCore

/// Minimal detail screen, here to show the Router passing data between scenes.
final class ListingDetailViewController: UIViewController {
    private let listing: Listing

    init(listing: Listing) {
        self.listing = listing
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used; the screen is created in code")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Item"
        view.backgroundColor = .systemBackground

        let titleLabel = makeLabel(listing.title, style: .title2)
        let brandLabel = makeLabel("\(listing.brand) · size \(listing.size)", style: .body, color: .secondaryLabel)
        let priceLabel = makeLabel(MoneyFormatter.euros(cents: listing.priceCents), style: .title3)
        let sellerLabel = makeLabel("Sold by \(listing.sellerName)", style: .footnote, color: .secondaryLabel)

        let stack = UIStackView(arrangedSubviews: [titleLabel, brandLabel, priceLabel, sellerLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    private func makeLabel(
        _ text: String,
        style: UIFont.TextStyle,
        color: UIColor = .label
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = color
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }
}

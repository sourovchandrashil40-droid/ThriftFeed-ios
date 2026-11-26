import UIKit
import ThriftFeedCore

final class ListingCell: UITableViewCell {
    static let reuseIdentifier = "ListingCell"

    var onFavoriteTapped: (() -> Void)?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let priceLabel = UILabel()
    private let secondaryPriceLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used; the cell is created in code")
    }

    func configure(with row: Feed.Row) {
        titleLabel.text = row.title
        subtitleLabel.text = row.subtitle
        priceLabel.text = row.priceText
        secondaryPriceLabel.text = row.secondaryPriceText
        secondaryPriceLabel.isHidden = row.secondaryPriceText == nil

        let imageName = row.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = row.isFavorite ? .systemRed : .secondaryLabel
        favoriteButton.accessibilityLabel = row.favoriteAccessibilityLabel
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onFavoriteTapped = nil
    }

    @objc private func favoriteTapped() {
        onFavoriteTapped?()
    }

    private func setUp() {
        accessoryType = .disclosureIndicator

        style(titleLabel, textStyle: .headline, color: .label)
        style(subtitleLabel, textStyle: .subheadline, color: .secondaryLabel)
        style(priceLabel, textStyle: .body, color: .label)
        style(secondaryPriceLabel, textStyle: .footnote, color: .secondaryLabel)

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        favoriteButton.setContentHuggingPriority(.required, for: .horizontal)
        favoriteButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, priceLabel, secondaryPriceLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let rootStack = UIStackView(arrangedSubviews: [textStack, favoriteButton])
        rootStack.axis = .horizontal
        rootStack.alignment = .center
        rootStack.spacing = 12
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            rootStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }

    private func style(_ label: UILabel, textStyle: UIFont.TextStyle, color: UIColor) {
        label.font = .preferredFont(forTextStyle: textStyle)
        label.textColor = color
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
    }
}

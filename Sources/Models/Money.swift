import Foundation

/// Formats integer cents as a euro string, e.g. 1250 -> "€12.50".
/// Written by hand (instead of NumberFormatter) so output is identical on every platform and locale,
/// which keeps the unit tests deterministic. A production app would use a locale-aware formatter.
public enum MoneyFormatter {
    public static func euros(cents: Int) -> String {
        let whole = cents / 100
        let fraction = cents % 100
        let paddedFraction = fraction < 10 ? "0\(fraction)" : "\(fraction)"
        return "€\(whole).\(paddedFraction)"
    }
}

/// Buyer fee used by the price-display experiment.
/// NOTE: these numbers are made up for the demo and are not any real marketplace's fee.
public enum PricingCalculator {
    public static let fixedFeeCents = 70
    public static let percentageFee = 5

    public static func buyerProtectionFeeCents(forItemPriceCents price: Int) -> Int {
        fixedFeeCents + (price * percentageFee) / 100
    }

    public static func totalCents(forItemPriceCents price: Int) -> Int {
        price + buyerProtectionFeeCents(forItemPriceCents: price)
    }
}

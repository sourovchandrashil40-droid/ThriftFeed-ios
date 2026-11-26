import XCTest
@testable import ThriftFeedCore

final class PricingAndMoneyTests: XCTestCase {
    func testFormatsWholeAndFractionalAmounts() {
        XCTAssertEqual(MoneyFormatter.euros(cents: 1250), "€12.50")
        XCTAssertEqual(MoneyFormatter.euros(cents: 1000), "€10.00")
    }

    func testPadsSingleDigitCents() {
        XCTAssertEqual(MoneyFormatter.euros(cents: 5), "€0.05")
        XCTAssertEqual(MoneyFormatter.euros(cents: 2801), "€28.01")
    }

    func testBuyerProtectionFeeIsFixedPlusPercentage() {
        // 70 cents fixed + 5% of 1000 cents (50) = 120
        XCTAssertEqual(PricingCalculator.buyerProtectionFeeCents(forItemPriceCents: 1000), 120)
    }

    func testPercentageFeeRoundsDown() {
        // 5% of 399 cents = 19.95 -> 19 (integer division), plus 70 fixed
        XCTAssertEqual(PricingCalculator.buyerProtectionFeeCents(forItemPriceCents: 399), 89)
    }

    func testTotalIsItemPricePlusFee() {
        XCTAssertEqual(PricingCalculator.totalCents(forItemPriceCents: 1000), 1120)
    }
}

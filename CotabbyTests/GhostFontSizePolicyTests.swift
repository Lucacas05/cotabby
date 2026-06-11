import CoreGraphics
import XCTest
@testable import Cotabby

final class GhostFontSizePolicyTests: XCTestCase {
    private let minimum: CGFloat = 12
    private let estimatedMaximum: CGFloat = 15
    private let ratio: CGFloat = 0.78

    func test_exactCaretUsesDerivedSizeBelowUserMaximum() {
        XCTAssertEqual(resolve(caretHeight: 18, quality: .exact, maximum: 16), 14.04, accuracy: 0.001)
    }

    func test_exactCaretCannotExceedUserMaximum() {
        XCTAssertEqual(resolve(caretHeight: 120, quality: .exact, maximum: 16), 16)
    }

    func test_estimatedCaretUsesStricterGeometryCeiling() {
        XCTAssertEqual(resolve(caretHeight: 120, quality: .estimated, maximum: 18), 15)
    }

    func test_userMaximumBelowEstimatedCeilingStillWins() {
        XCTAssertEqual(resolve(caretHeight: 120, quality: .estimated, maximum: 13), 13)
    }

    func test_smallAndZeroCaretHeightsUseReadableMinimum() {
        XCTAssertEqual(resolve(caretHeight: 4, quality: .exact, maximum: 16), minimum)
        XCTAssertEqual(resolve(caretHeight: 0, quality: .exact, maximum: 16), minimum)
    }

    func test_nonFiniteAccessibilityValuesCannotReachRenderer() {
        XCTAssertEqual(resolve(caretHeight: .infinity, quality: .exact, maximum: 16), minimum)
        XCTAssertEqual(resolve(caretHeight: .nan, quality: .estimated, maximum: 16), minimum)
    }

    func test_invalidPreferredMaximumFallsBackToMinimum() {
        XCTAssertEqual(resolve(caretHeight: 120, quality: .exact, maximum: .nan), minimum)
        XCTAssertEqual(resolve(caretHeight: 120, quality: .exact, maximum: -10), minimum)
    }

    private func resolve(
        caretHeight: CGFloat,
        quality: CaretGeometryQuality,
        maximum: CGFloat
    ) -> CGFloat {
        GhostFontSizePolicy.resolve(
            caretHeight: caretHeight,
            caretQuality: quality,
            preferredMaximum: maximum,
            minimum: minimum,
            estimatedMaximum: estimatedMaximum,
            fontToLineHeightRatio: ratio
        )
    }
}

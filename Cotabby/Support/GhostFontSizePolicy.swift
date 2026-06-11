import CoreGraphics
import Foundation

/// Resolves a safe inline ghost-text font size from Accessibility caret geometry.
///
/// Accessibility rectangles are untrusted input: some apps return a true line-height caret, some
/// return the full editor frame, and transient failures can produce zero or non-finite values. This
/// pure policy keeps those platform quirks out of `OverlayController` and guarantees that the
/// renderer always receives a finite value within the user-visible size bounds.
enum GhostFontSizePolicy {
    static func resolve(
        caretHeight: CGFloat,
        caretQuality: CaretGeometryQuality,
        preferredMaximum: CGFloat,
        minimum: CGFloat,
        estimatedMaximum: CGFloat,
        fontToLineHeightRatio: CGFloat
    ) -> CGFloat {
        let safeMinimum = finitePositive(minimum, fallback: 12)
        let safePreferredMaximum = max(
            safeMinimum,
            finitePositive(preferredMaximum, fallback: safeMinimum)
        )
        let safeEstimatedMaximum = max(
            safeMinimum,
            finitePositive(estimatedMaximum, fallback: safeMinimum)
        )
        let safeRatio = finitePositive(fontToLineHeightRatio, fallback: 1)
        let safeCaretHeight = finitePositive(caretHeight, fallback: safeMinimum / safeRatio)

        let proposedSize = max(safeMinimum, safeCaretHeight * safeRatio)
        let qualityMaximum = caretQuality == .estimated
            ? min(safePreferredMaximum, safeEstimatedMaximum)
            : safePreferredMaximum

        return min(proposedSize, qualityMaximum)
    }

    private static func finitePositive(_ value: CGFloat, fallback: CGFloat) -> CGFloat {
        guard value.isFinite, value > 0 else {
            return fallback
        }
        return value
    }
}

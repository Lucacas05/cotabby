import SwiftUI

/// File overview:
/// The small affordance shown just outside a supported text field.
///
/// The fork intentionally avoids the old cat asset at the cursor edge. This is an availability
/// marker, not primary brand artwork, so a neutral SF Symbol keeps the typing surface quieter while
/// preserving the user's option to show a field indicator from Settings.
struct FieldEdgeIconIndicatorView: View {
    private let side: CGFloat = 20
    private let cornerRadius: CGFloat = 5

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(red: 0.18, green: 0.19, blue: 0.21))

            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
        .fixedSize()
    }
}

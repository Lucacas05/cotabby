import SwiftUI

/// Renders the product's shared brand artwork at the size required by each surface.
///
/// Keeping the asset behind this small view gives onboarding and Settings one ownership boundary
/// for sizing and interpolation. The app icon uses the same source artwork through `AppIcon`.
struct ProductMarkView: View {
    let size: CGFloat

    var body: some View {
        Image("ProductLogo")
            .resizable()
            .interpolation(.high)
            .antialiased(true)
            .aspectRatio(contentMode: .fit)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

import Foundation

/// Central product-facing identity for the app.
///
/// A fork needs one small boundary where brand name, support destinations, and public resources
/// can change without hunting through SwiftUI views. Keep runtime names, UserDefaults keys, and
/// module names out of this type: those are compatibility boundaries, not marketing copy.
enum ProductIdentity {
    /// User-facing product name supplied by the app bundle.
    ///
    /// `CFBundleDisplayName` intentionally differs from the inherited target/executable name. That
    /// lets Finder, permission surfaces, and SwiftUI agree on the fork's visible identity without
    /// prematurely renaming modules, persistence paths, or compatibility keys.
    static let displayName =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? "AutoComplete"

    static let tagline = "Local macOS AI Autocomplete"

    /// Set these once the fork has its own public destinations. Nil intentionally hides upstream
    /// Cotabby links so a redistributed build does not send users to the original project's
    /// support, feedback, or documentation surfaces.
    static let supportURL: URL? = nil
    static let feedbackURL: URL? = nil
    static let repositoryURL: URL? = nil
    static let documentationURL: URL? = nil
}

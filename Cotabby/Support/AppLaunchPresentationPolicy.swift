import Foundation

/// Decides whether a completed user's initial app launch should present Settings.
///
/// Manual launches should feel like opening a graphical app, while login-item and service launches
/// must stay quiet. Onboarding and permission windows already own the user's attention and therefore
/// take precedence over Settings regardless of launch source.
enum AppLaunchPresentationPolicy {
    static func shouldShowSettings(
        launchedAsLoginItem: Bool,
        launchedAsServiceItem: Bool,
        hasPriorityWindow: Bool
    ) -> Bool {
        !launchedAsLoginItem
            && !launchedAsServiceItem
            && !hasPriorityWindow
    }
}

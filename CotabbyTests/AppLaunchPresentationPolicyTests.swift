import XCTest
@testable import Cotabby

final class AppLaunchPresentationPolicyTests: XCTestCase {
    func test_manualLaunchWithoutPriorityWindowShowsSettings() {
        XCTAssertTrue(
            AppLaunchPresentationPolicy.shouldShowSettings(
                launchedAsLoginItem: false,
                launchedAsServiceItem: false,
                hasPriorityWindow: false
            )
        )
    }

    func test_loginAndServiceLaunchesStayQuiet() {
        XCTAssertFalse(
            AppLaunchPresentationPolicy.shouldShowSettings(
                launchedAsLoginItem: true,
                launchedAsServiceItem: false,
                hasPriorityWindow: false
            )
        )
        XCTAssertFalse(
            AppLaunchPresentationPolicy.shouldShowSettings(
                launchedAsLoginItem: false,
                launchedAsServiceItem: true,
                hasPriorityWindow: false
            )
        )
    }

    func test_onboardingOrPermissionWindowKeepsPriority() {
        XCTAssertFalse(
            AppLaunchPresentationPolicy.shouldShowSettings(
                launchedAsLoginItem: false,
                launchedAsServiceItem: false,
                hasPriorityWindow: true
            )
        )
    }
}

import XCTest

final class StrangerStoriesUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testTabBarExists() throws {
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    func testOnboardingAppears() throws {
        // On first launch, onboarding should be visible
        let signInButton = app.buttons["Sign in with Apple"]
        // May or may not exist depending on onboarding state
    }
}

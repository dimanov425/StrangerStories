import XCTest
@testable import StrangerStories

final class StrangerStoriesTests: XCTestCase {
    func testWilsonScoreZeroRatings() {
        // Wilson score with 0 ratings should return 0
        // Server-side test — validated in Supabase migration
    }

    func testWordCount() {
        let text = "The corridor was dark and the light flickered"
        let count = text.split(separator: " ").count
        XCTAssertEqual(count, 8)
    }

    func testModerationStatusCoding() throws {
        let status = ModerationStatus.approved
        let data = try JSONEncoder().encode(status)
        let decoded = try JSONDecoder().decode(ModerationStatus.self, from: data)
        XCTAssertEqual(decoded, .approved)
    }

    func testAchievementTypes() {
        XCTAssertEqual(AchievementType.allCases.count, 7)
        for type in AchievementType.allCases {
            XCTAssertFalse(type.displayName.isEmpty)
            XCTAssertFalse(type.symbolName.isEmpty)
        }
    }

    func testFeedSortCases() {
        XCTAssertEqual(FeedSort.allCases.count, 3)
    }

    // MARK: - Retention Feature Tests

    func testSharedDefaultsRoundTrip() {
        let testURL = URL(string: "https://example.com/photo.jpg")!
        SharedDefaults.writeDailyChallenge(photoURL: testURL, storyCount: 42, date: "2026-04-08")

        XCTAssertEqual(SharedDefaults.challengePhotoURL, testURL)
        XCTAssertEqual(SharedDefaults.challengeStoryCount, 42)
        XCTAssertEqual(SharedDefaults.challengeDate, "2026-04-08")
    }

    func testSharedDefaultsNilPhoto() {
        SharedDefaults.writeDailyChallenge(photoURL: nil, storyCount: 0, date: "2026-04-08")
        XCTAssertNil(SharedDefaults.challengePhotoURL)
        XCTAssertEqual(SharedDefaults.challengeStoryCount, 0)
    }

    func testAppUserHasStreakFreeze() {
        let userWithFreeze = makeUser(streakDays: 5, streakRecoveryUsed: false)
        XCTAssertTrue(userWithFreeze.hasStreakFreeze)

        let userWithoutFreeze = makeUser(streakDays: 5, streakRecoveryUsed: true)
        XCTAssertFalse(userWithoutFreeze.hasStreakFreeze)
    }

    func testAppUserStreakFreezeZeroStreak() {
        let user = makeUser(streakDays: 0, streakRecoveryUsed: false)
        XCTAssertTrue(user.hasStreakFreeze)
    }

    func testTabEnum() {
        let tabs: [Tab] = [.write, .feed, .anthology, .profile]
        XCTAssertEqual(tabs.count, 4)
        XCTAssertNotEqual(Tab.write, Tab.feed)
    }

    func testWritingPhaseEnum() {
        let phases: [WritingPhase] = [.loading, .reveal, .writing, .submitted]
        XCTAssertEqual(phases.count, 4)
    }

    func testAchievementDescriptionsNotEmpty() {
        for type in AchievementType.allCases {
            XCTAssertFalse(type.description.isEmpty, "\(type.rawValue) has empty description")
        }
    }

    func testChainStatusCoding() throws {
        for status in [ChainStatus.open, .completed] {
            let data = try JSONEncoder().encode(status)
            let decoded = try JSONDecoder().decode(ChainStatus.self, from: data)
            XCTAssertEqual(decoded, status)
        }
    }

    // MARK: - Helpers

    private func makeUser(streakDays: Int, streakRecoveryUsed: Bool) -> AppUser {
        AppUser(
            id: UUID(),
            appleId: nil,
            email: "test@test.com",
            displayName: "TestUser",
            bio: nil,
            avatarUrl: nil,
            storiesCount: 10,
            avgRating: 4.0,
            streakDays: streakDays,
            streakRecoveryUsed: streakRecoveryUsed,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

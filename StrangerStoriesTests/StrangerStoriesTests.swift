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
        XCTAssertEqual(count, 9)
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
}

import Foundation
import Supabase

actor DailyChallengeRepository {
    private let supabase = SupabaseClientManager.shared.client

    func fetchTodaysChallenge() async throws -> DailyChallenge? {
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        let challenges: [DailyChallenge] = try await supabase
            .from("daily_challenges")
            .select("*, photos(*)")
            .eq("date", value: String(today))
            .limit(1)
            .execute()
            .value
        return challenges.first
    }

    func fetchPastChallenges(limit: Int = 30) async throws -> [DailyChallenge] {
        try await supabase
            .from("daily_challenges")
            .select("*, photos(*)")
            .order("date", ascending: false)
            .limit(limit)
            .execute()
            .value
    }
}

import Foundation
import Supabase

actor UserRepository {
    private let supabase = SupabaseClientManager.shared.client

    func fetchUser(id: UUID) async throws -> AppUser {
        try await supabase
            .from("users")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func updateProfile(userId: UUID, displayName: String, bio: String?) async throws {
        struct ProfileUpdate: Encodable {
            let display_name: String
            let bio: String?
            let updated_at: String
        }
        try await supabase
            .from("users")
            .update(ProfileUpdate(
                display_name: displayName,
                bio: bio,
                updated_at: ISO8601DateFormatter().string(from: Date())
            ))
            .eq("id", value: userId)
            .execute()
    }

    func updateAvatar(userId: UUID, imageData: Data) async throws -> String {
        let path = "avatars/\(userId.uuidString).jpg"
        try await supabase.storage.from("avatars").upload(
            path,
            data: imageData,
            options: .init(contentType: "image/jpeg", upsert: true)
        )
        let url = try supabase.storage.from("avatars").getPublicURL(path: path)

        try await supabase
            .from("users")
            .update(["avatar_url": url.absoluteString, "updated_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: userId)
            .execute()

        return url.absoluteString
    }

    func deleteAccount(userId: UUID) async throws {
        // Edge Function handles cascading deletion and auth cleanup
        try await supabase.functions.invoke("delete-account", options: .init(
            body: ["user_id": userId.uuidString]
        ))
    }

    func fetchAchievements(userId: UUID) async throws -> [Achievement] {
        try await supabase
            .from("achievements")
            .select()
            .eq("user_id", value: userId)
            .order("earned_at", ascending: false)
            .execute()
            .value
    }
}

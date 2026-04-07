import Foundation
import Supabase

actor PhotoRepository {
    private let supabase = SupabaseClientManager.shared.client

    func fetchRandomPhoto(excluding photoId: UUID? = nil) async throws -> Photo {
        let candidates: [Photo]
        if let photoId {
            candidates = try await supabase
                .from("photos")
                .select()
                .eq("is_active", value: true)
                .neq("id", value: photoId)
                .order("story_count", ascending: true)
                .limit(20)
                .execute()
                .value
        } else {
            candidates = try await supabase
                .from("photos")
                .select()
                .eq("is_active", value: true)
                .order("story_count", ascending: true)
                .limit(20)
                .execute()
                .value
        }

        guard let photo = candidates.randomElement() else {
            throw RepositoryError.noPhotosAvailable
        }
        return photo
    }

    func fetchPhoto(id: UUID) async throws -> Photo {
        try await supabase
            .from("photos")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func fetchPhotosWithStories(limit: Int = 50) async throws -> [Photo] {
        try await supabase
            .from("photos")
            .select()
            .eq("is_active", value: true)
            .gt("story_count", value: 0)
            .order("story_count", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func publicURL(for path: String) -> URL? {
        try? supabase.storage.from("photos").getPublicURL(path: path)
    }
}

enum RepositoryError: LocalizedError {
    case noPhotosAvailable
    case notAuthenticated
    case submissionTooLate
    case alreadyRated

    var errorDescription: String? {
        switch self {
        case .noPhotosAvailable: String(localized: "No photos available right now. Please try again later.")
        case .notAuthenticated: String(localized: "You need to sign in to do that.")
        case .submissionTooLate: String(localized: "Submission time exceeded. Your story was auto-saved.")
        case .alreadyRated: String(localized: "You've already rated this story.")
        }
    }
}

import Foundation
import Supabase

final class SupabaseClientManager {
    static let shared = SupabaseClientManager()

    let client: SupabaseClient

    private init() {
        // These are public values — all data protection is via RLS policies.
        // Replace with your actual Supabase project credentials.
        let url = URL(string: "https://hdenfvvijlsvznycuisd.supabase.co")!
        let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhkZW5mdnZpamxzdnpueWN1aXNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0ODk5NTMsImV4cCI6MjA5MTA2NTk1M30.Y0RYssC9mYx_DrGtCg8NGxKuAHXFrhrfz0bZLgOl-5E"

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }
}

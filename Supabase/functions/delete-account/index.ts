import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  try {
    const { user_id: userId } = await req.json();

    if (!userId) {
      return new Response(JSON.stringify({ error: "user_id required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    // Anonymize stories (keep content but remove author link)
    await supabase
      .from("stories")
      .update({ user_id: null })
      .eq("user_id", userId);

    // Delete user data (cascades via FK constraints for ratings, bookmarks, etc.)
    await supabase.from("auto_saves").delete().eq("user_id", userId);
    await supabase.from("achievements").delete().eq("user_id", userId);
    await supabase.from("bookmarks").delete().eq("user_id", userId);
    await supabase.from("ratings").delete().eq("user_id", userId);
    await supabase.from("reports").delete().eq("reporter_id", userId);
    await supabase.from("users").delete().eq("id", userId);

    // Delete auth user
    const { error } = await supabase.auth.admin.deleteUser(userId);
    if (error) {
      console.error("Failed to delete auth user:", error);
    }

    return new Response(JSON.stringify({ status: "deleted" }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

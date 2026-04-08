import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  try {
    // Verify the caller is authenticated — they can only delete their own account
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }
    const token = authHeader.replace("Bearer ", "");
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const userId = user.id;
    const errors: string[] = [];

    // Anonymize stories: set user_id to a sentinel "deleted user" UUID
    // (user_id is NOT NULL, so we use a placeholder instead of null)
    const DELETED_USER_ID = "00000000-0000-0000-0000-000000000000";
    const { error: anonError } = await supabase
      .from("stories")
      .update({ user_id: DELETED_USER_ID, mod_status: "approved" })
      .eq("user_id", userId);
    if (anonError) errors.push(`stories anonymization: ${anonError.message}`);

    // Delete from all user-linked tables (order matters for FK constraints)
    const deletions = [
      { table: "auto_saves", column: "user_id" },
      { table: "story_swipes", column: "user_id" },
      { table: "chapters", column: "user_id" },
      { table: "achievements", column: "user_id" },
      { table: "bookmarks", column: "user_id" },
      { table: "ratings", column: "user_id" },
      { table: "reports", column: "reporter_id" },
      { table: "device_tokens", column: "user_id" },
    ];
    for (const { table, column } of deletions) {
      const { error: delError } = await supabase.from(table).delete().eq(column, userId);
      if (delError) errors.push(`${table}: ${delError.message}`);
    }

    // Delete the user row
    const { error: userDelError } = await supabase.from("users").delete().eq("id", userId);
    if (userDelError) errors.push(`users: ${userDelError.message}`);

    // Delete auth user
    const { error: authDelError } = await supabase.auth.admin.deleteUser(userId);
    if (authDelError) errors.push(`auth: ${authDelError.message}`);

    if (errors.length > 0) {
      console.error("Partial deletion errors:", errors);
      return new Response(
        JSON.stringify({ status: "partial", errors }),
        { status: 207, headers: { "Content-Type": "application/json" } }
      );
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

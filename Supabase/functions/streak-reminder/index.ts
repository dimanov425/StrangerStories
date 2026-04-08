import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Scheduled via Supabase Cron (e.g. 20:00 UTC daily).
// Finds users with active streaks who haven't written today
// and sends a push reminder via their registered device tokens.
serve(async (_req) => {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
  const today = new Date().toISOString().split("T")[0];

  // Users with active streaks who have NOT submitted a story today
  const { data: atRiskUsers, error: queryError } = await supabase
    .from("users")
    .select("id, streak_days, display_name")
    .gt("streak_days", 0);

  if (queryError || !atRiskUsers) {
    return new Response(
      JSON.stringify({ error: queryError?.message ?? "no_data" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  const remindersSent: string[] = [];

  for (const user of atRiskUsers) {
    // Check if user wrote today
    const { count } = await supabase
      .from("stories")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
      .gte("created_at", `${today}T00:00:00Z`);

    if ((count ?? 0) > 0) continue;

    // Get device tokens
    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", user.id);

    if (!tokens || tokens.length === 0) continue;

    // In production, send APNs push here via a push provider.
    // This placeholder logs the intent.
    remindersSent.push(user.id);
  }

  return new Response(
    JSON.stringify({
      status: "completed",
      reminders_queued: remindersSent.length,
    }),
    { headers: { "Content-Type": "application/json" } }
  );
});

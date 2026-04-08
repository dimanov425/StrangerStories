import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Called by Supabase Cron at midnight UTC
serve(async (req) => {
  // Only allow service role key (cron scheduler)
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ") || authHeader.replace("Bearer ", "") !== SUPABASE_SERVICE_KEY) {
    return new Response(JSON.stringify({ error: "unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
  const today = new Date().toISOString().split("T")[0];

  // Check if today's challenge already exists
  const { data: existing } = await supabase
    .from("daily_challenges")
    .select("id")
    .eq("date", today)
    .maybeSingle();

  if (existing) {
    return new Response(JSON.stringify({ status: "already_exists" }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  // Get recently used challenge photo IDs (last 30 days)
  const thirtyDaysAgo = new Date(Date.now() - 30 * 86400000)
    .toISOString()
    .split("T")[0];
  const { data: recentChallenges } = await supabase
    .from("daily_challenges")
    .select("photo_id")
    .gte("date", thirtyDaysAgo);

  const recentPhotoIds = (recentChallenges || []).map(
    (c: { photo_id: string }) => c.photo_id
  );

  // Select a photo: active, fewest stories, not recently used
  let query = supabase
    .from("photos")
    .select("id")
    .eq("is_active", true)
    .order("story_count", { ascending: true })
    .limit(20);

  const { data: candidates } = await query;
  const eligible = (candidates || []).filter(
    (p: { id: string }) => !recentPhotoIds.includes(p.id)
  );

  const selected =
    eligible.length > 0
      ? eligible[Math.floor(Math.random() * eligible.length)]
      : candidates?.[0];

  if (!selected) {
    return new Response(JSON.stringify({ error: "no_photos_available" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  await supabase
    .from("daily_challenges")
    .insert({ photo_id: selected.id, date: today });

  // Queue push notifications for all users with registered device tokens.
  // In production, iterate tokens and send APNs payloads via a push provider.
  const { count: tokenCount } = await supabase
    .from("device_tokens")
    .select("id", { count: "exact", head: true });

  return new Response(
    JSON.stringify({
      status: "created",
      photo_id: selected.id,
      push_targets: tokenCount ?? 0,
    }),
    { headers: { "Content-Type": "application/json" } }
  );
});

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

interface ModerationPayload {
  type: "INSERT";
  table: "stories";
  record: {
    id: string;
    content: string;
    user_id: string;
  };
}

serve(async (req) => {
  try {
    const payload: ModerationPayload = await req.json();
    const { id: storyId, content, user_id: userId } = payload.record;

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    // Check if user is shadowbanned (3+ rejected stories)
    const { count: rejectedCount } = await supabase
      .from("stories")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("mod_status", "rejected");

    if (rejectedCount && rejectedCount >= 3) {
      // Shadowbanned — hold for manual review
      await supabase
        .from("stories")
        .update({ mod_status: "pending", is_published: false })
        .eq("id", storyId);

      return new Response(JSON.stringify({ status: "held_for_review" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Call OpenAI Moderation API
    const moderationResponse = await fetch(
      "https://api.openai.com/v1/moderations",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ input: content }),
      }
    );

    if (!moderationResponse.ok) {
      // API unreachable — hold for manual review
      await supabase
        .from("stories")
        .update({ mod_status: "pending", is_published: false })
        .eq("id", storyId);

      return new Response(
        JSON.stringify({ status: "pending", reason: "moderation_api_error" }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    const moderationResult = await moderationResponse.json();
    const isFlagged = moderationResult.results?.[0]?.flagged ?? false;

    if (isFlagged) {
      await supabase
        .from("stories")
        .update({
          mod_status: "flagged",
          is_published: false,
          is_flagged: true,
        })
        .eq("id", storyId);

      return new Response(JSON.stringify({ status: "flagged" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Content is clean — publish
    await supabase
      .from("stories")
      .update({
        mod_status: "approved",
        is_published: true,
      })
      .eq("id", storyId);

    return new Response(JSON.stringify({ status: "approved" }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

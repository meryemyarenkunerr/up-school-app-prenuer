import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

Deno.serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "missing_auth_header" }, 401);
  }

  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: authUser, error: authError } = await client.auth.getUser();
  if (authError || !authUser.user) {
    return json({ error: "unauthorized" }, 401);
  }

  const { data: profile, error: profileError } = await client
    .from("profiles")
    .select("id, display_name, avatar_url, nationality, role")
    .eq("id", authUser.user.id)
    .single();

  if (profileError) {
    return json({ error: "profile_not_found" }, 404);
  }

  return json(profile, 200);
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}

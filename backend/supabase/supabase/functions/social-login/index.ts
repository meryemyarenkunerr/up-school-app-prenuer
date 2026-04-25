import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type SocialProvider = "google" | "apple";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const adminClient = createClient(supabaseUrl, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.json();
  const provider = body.provider as SocialProvider;
  const idToken = body.id_token as string;
  const deviceHash = body.device_hash as string;

  if (!provider || !idToken || !deviceHash) {
    return json({ error: "missing_required_fields" }, 400);
  }

  if (provider !== "google" && provider !== "apple") {
    return json({ error: "invalid_provider" }, 400);
  }

  // Supabase social login tokens are exchanged with signInWithIdToken.
  const { data: authData, error: authError } = await adminClient.auth.signInWithIdToken({
    provider,
    token: idToken,
  });

  if (authError || !authData.user || !authData.session) {
    return json({ error: "token_exchange_failed" }, 401);
  }

  const displayName = authData.user.user_metadata?.full_name ??
    authData.user.user_metadata?.name ??
    "";
  const avatarUrl = authData.user.user_metadata?.avatar_url ?? "";

  const { error: profileError } = await adminClient.rpc("upsert_profile_on_social_login", {
    p_user_id: authData.user.id,
    p_device_hash: deviceHash,
    p_display_name: displayName,
    p_avatar_url: avatarUrl,
  });

  if (profileError) {
    return json({ error: "profile_upsert_failed", detail: profileError.message }, 500);
  }

  return json({
    access_token: authData.session.access_token,
    refresh_token: authData.session.refresh_token,
    user_id: authData.user.id,
  });
});

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}

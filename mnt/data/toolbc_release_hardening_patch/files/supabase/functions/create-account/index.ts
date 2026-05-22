import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const allowedRoles = new Set(["patient", "doctor", "admin"]);

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const supabaseUrl = requireEnv("SUPABASE_URL");
    const supabaseAnonKey = requireEnv("SUPABASE_ANON_KEY");
    const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");

    const authHeader = req.headers.get("Authorization") ?? "";
    const callerClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });

    const { data: callerAuth, error: callerError } = await callerClient.auth.getUser();
    if (callerError || !callerAuth.user) {
      return json({ error: "Unauthorized" }, 401);
    }

    const { data: callerProfile, error: callerProfileError } = await callerClient
      .from("profiles")
      .select("role")
      .eq("id", callerAuth.user.id)
      .single();

    if (callerProfileError || callerProfile?.role !== "admin") {
      return json({ error: "Hanya admin yang boleh membuat akun." }, 403);
    }

    const body = await req.json().catch(() => ({}));
    const email = stringField(body.email).toLowerCase();
    const password = stringField(body.password);
    const fullName = stringField(body.full_name);
    const role = stringField(body.role);
    const specialty = optionalString(body.specialty);
    const assignedDoctorId = optionalString(body.assigned_doctor_id);

    if (!email || !password || !fullName || !allowedRoles.has(role)) {
      return json({ error: "email, password, full_name, dan role valid wajib diisi." }, 400);
    }

    if (password.length < 8) {
      return json({ error: "Password minimal 8 karakter." }, 400);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const { data: created, error: createError } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: fullName,
        role,
      },
    });

    if (createError || !created.user) {
      return json({ error: createError?.message ?? "Gagal membuat user." }, 400);
    }

    const profilePayload: Record<string, unknown> = {
      id: created.user.id,
      full_name: fullName,
      email,
      role,
      specialty: role === "doctor" ? specialty : null,
      assigned_doctor_id: role === "patient" ? assignedDoctorId : null,
    };

    const { data: profile, error: profileError } = await adminClient
      .from("profiles")
      .upsert(profilePayload, { onConflict: "id" })
      .select()
      .single();

    if (profileError) {
      await adminClient.auth.admin.deleteUser(created.user.id);
      return json({ error: profileError.message }, 400);
    }

    return json({ user_id: created.user.id, profile }, 201);
  } catch (error) {
    console.error(error);
    return json({ error: "Internal server error" }, 500);
  }
});

function stringField(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function optionalString(value: unknown): string | null {
  const text = stringField(value);
  return text.length > 0 ? text : null;
}

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured`);
  return value;
}

function json(payload: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

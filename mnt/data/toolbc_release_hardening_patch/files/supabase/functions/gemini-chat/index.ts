import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

type ChatTurn = {
  text?: unknown;
  fromUser?: unknown;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

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
    const geminiApiKey = requireEnv("GEMINI_API_KEY");
    const geminiModel = Deno.env.get("GEMINI_MODEL") ?? "gemini-1.5-flash";

    const authHeader = req.headers.get("Authorization") ?? "";
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });

    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) {
      return json({ error: "Unauthorized" }, 401);
    }

    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", userData.user.id)
      .single();

    if (profileError || !profile?.role) {
      return json({ error: "Profil pengguna tidak ditemukan." }, 403);
    }

    const body = await req.json().catch(() => ({}));
    const history = normalizeHistory(body.history);
    if (history.length === 0) {
      return json({ error: "Riwayat chat kosong." }, 400);
    }

    const requestedMode = typeof body.mode === "string" ? body.mode : profile.role;
    const mode = ["patient", "doctor", "admin"].includes(requestedMode)
      ? requestedMode
      : profile.role;

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent?key=${geminiApiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          systemInstruction: {
            parts: [{ text: systemPrompt(mode) }],
          },
          contents: history.map((turn) => ({
            role: turn.fromUser ? "user" : "model",
            parts: [{ text: turn.text }],
          })),
          generationConfig: {
            temperature: 0.45,
            topP: 0.9,
            maxOutputTokens: 360,
          },
        }),
      },
    );

    const geminiJson = await geminiResponse.json().catch(() => ({}));
    if (!geminiResponse.ok) {
      console.error("Gemini API error", geminiResponse.status, geminiJson);
      return json({ error: "Layanan AI bermasalah. Coba lagi sebentar lagi." }, 502);
    }

    const text = extractText(geminiJson);
    if (!text) {
      return json({ error: "AI tidak mengirim jawaban." }, 502);
    }

    return json({ text });
  } catch (error) {
    console.error(error);
    return json({ error: "Internal server error" }, 500);
  }
});

function normalizeHistory(input: unknown): Array<{ text: string; fromUser: boolean }> {
  if (!Array.isArray(input)) return [];

  return input
    .slice(-8)
    .map((item: ChatTurn) => ({
      text: typeof item?.text === "string" ? item.text.trim().slice(0, 2000) : "",
      fromUser: item?.fromUser === true,
    }))
    .filter((item) => item.text.length > 0);
}

function extractText(body: Record<string, unknown>): string | null {
  const candidates = body.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) return null;

  const first = candidates[0] as Record<string, unknown>;
  const content = first.content as Record<string, unknown> | undefined;
  const parts = content?.parts;
  if (!Array.isArray(parts)) return null;

  const chunks = parts
    .map((part) => (part as Record<string, unknown>).text)
    .filter((text): text is string => typeof text === "string" && text.trim().length > 0);

  const text = chunks.join("\n").trim();
  return text.length > 0 ? text : null;
}

function systemPrompt(mode: string): string {
  const roleName = mode === "doctor"
    ? "dokter"
    : mode === "admin"
      ? "admin/resepsionis"
      : "pasien/user";

  return `Kamu AI ToolBC/TBC Care untuk role ${roleName}. Jawab singkat, jelas, dan dalam Bahasa Indonesia.
Konteks: ToolBC membantu pemantauan pengobatan TBC, kepatuhan minum obat, checkup harian, reminder, riwayat progres, dan komunikasi perawatan.
Batasan medis: beri edukasi umum, bukan diagnosis, bukan pengganti dokter, dan jangan mengubah dosis/obat. Untuk sesak berat, batuk darah, nyeri dada berat, pingsan, alergi berat, atau demam tinggi menetap, sarankan bantuan medis segera. Masalah akun diarahkan ke admin/resepsionis.`;
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

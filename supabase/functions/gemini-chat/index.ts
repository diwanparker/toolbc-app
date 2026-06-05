import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

type ChatTurn = {
  text?: unknown;
  fromUser?: unknown;
};

type ChatMessage = {
  text: string;
  fromUser: boolean;
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
    const text = await generateAiReply(mode, history);

    return json({ text });
  } catch (error) {
    console.error(error);
    return json({ error: "Internal server error" }, 500);
  }
});

async function generateAiReply(mode: string, history: ChatMessage[]): Promise<string> {
  const provider = preferredProvider();
  const providers = provider === "openai" ? ["openai", "gemini"] : ["gemini", "openai"];

  for (const item of providers) {
    try {
      if (item === "openai" && hasOpenAiKey()) {
        return await generateOpenAiReply(mode, history);
      }

      if (item === "gemini" && geminiApiKeys().length > 0) {
        return await generateGeminiReply(mode, history);
      }
    } catch (error) {
      console.error(`${item} provider failed`, error);
    }
  }

  throw new Error("No AI provider is configured");
}

async function generateOpenAiReply(mode: string, history: ChatMessage[]): Promise<string> {
  const apiKey = requireEnv("OPENAI_API_KEY");
  const model = Deno.env.get("OPENAI_MODEL") ?? "gpt-5-mini";

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      instructions: systemPrompt(mode),
      input: history.map((turn) => ({
        role: turn.fromUser ? "user" : "assistant",
        content: turn.text,
      })),
      max_output_tokens: 360,
    }),
  });

  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(`OpenAI API error ${response.status}: ${JSON.stringify(body)}`);
  }

  const text = extractOpenAiText(body);
  if (!text) {
    throw new Error("OpenAI response did not include text");
  }

  return text;
}

async function generateGeminiReply(mode: string, history: ChatMessage[]): Promise<string> {
  const apiKeys = geminiApiKeys();
  if (apiKeys.length === 0) {
    throw new Error("Gemini API key is not configured");
  }

  const errors: string[] = [];
  for (const [index, apiKey] of apiKeys.entries()) {
    try {
      return await generateGeminiReplyWithKey(apiKey, mode, history);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      errors.push(`key ${index + 1}: ${message}`);
      console.error(`Gemini provider failed for configured key ${index + 1}`, message);
    }
  }

  throw new Error(`Gemini failed for ${apiKeys.length} configured key(s): ${errors.join(" | ")}`);
}

async function generateGeminiReplyWithKey(
  apiKey: string,
  mode: string,
  history: ChatMessage[],
): Promise<string> {
  const model = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey,
    },
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
  });

  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(`Gemini API error ${response.status}: ${JSON.stringify(body)}`);
  }

  const text = extractGeminiText(body);
  if (!text) {
    throw new Error("Gemini response did not include text");
  }

  return text;
}

function preferredProvider(): string {
  const configured = Deno.env.get("AI_PROVIDER")?.trim().toLowerCase();
  if (configured === "gemini" || configured === "openai") {
    return configured;
  }

  return hasOpenAiKey() ? "openai" : "gemini";
}

function hasOpenAiKey(): boolean {
  return !!Deno.env.get("OPENAI_API_KEY")?.trim();
}

function geminiApiKeys(): string[] {
  const keys = [
    ...splitEnvList("GEMINI_API_KEYS"),
    Deno.env.get("GEMINI_API_KEY_1"),
    Deno.env.get("GEMINI_API_KEY_2"),
    Deno.env.get("GEMINI_API_KEY_3"),
    Deno.env.get("GEMINI_API_KEY"),
  ]
    .map((key) => key?.trim() ?? "")
    .filter((key) => key.length > 0);

  return [...new Set(keys)];
}

function splitEnvList(name: string): string[] {
  return (Deno.env.get(name) ?? "")
    .split(",")
    .map((key) => key.trim())
    .filter((key) => key.length > 0);
}

function normalizeHistory(input: unknown): ChatMessage[] {
  if (!Array.isArray(input)) return [];

  return input
    .slice(-8)
    .map((item: ChatTurn) => ({
      text: typeof item?.text === "string" ? item.text.trim().slice(0, 2000) : "",
      fromUser: item?.fromUser === true,
    }))
    .filter((item) => item.text.length > 0);
}

function extractOpenAiText(body: Record<string, unknown>): string | null {
  if (typeof body.output_text === "string" && body.output_text.trim().length > 0) {
    return body.output_text.trim();
  }

  const output = body.output;
  if (!Array.isArray(output)) return null;

  const chunks = output.flatMap((item) => {
    const content = (item as Record<string, unknown>).content;
    if (!Array.isArray(content)) return [];

    return content
      .map((part) => (part as Record<string, unknown>).text)
      .filter((text): text is string => typeof text === "string" && text.trim().length > 0);
  });

  const text = chunks.join("\n").trim();
  return text.length > 0 ? text : null;
}

function extractGeminiText(body: Record<string, unknown>): string | null {
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

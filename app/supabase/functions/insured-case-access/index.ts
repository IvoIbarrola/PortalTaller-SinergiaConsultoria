import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json; charset=utf-8" },
  });
}

function digits(value: unknown): string {
  return String(value ?? "").replace(/\D/g, "");
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Método no permitido." }, 405);

  let body: { claimNumber?: string; phone?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Solicitud inválida." }, 400);
  }

  const claimNumber = String(body.claimNumber ?? "").trim();
  const phone = digits(body.phone);
  if (!claimNumber || phone.length < 8 || phone.length > 15) {
    return json({ error: "Ingresá el número de siniestro y el celular registrado." }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceKey) {
    return json({ error: "Servicio temporalmente no disponible." }, 503);
  }

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: repairCase, error } = await admin
    .from("repair_cases")
    .select("id, claim_number, status, progress, description, entry_date, estimated_delivery_date, vehicle_id, workshop_id, insured_phone")
    .eq("claim_number", claimNumber)
    .maybeSingle();

  if (error) {
    console.error("insured-case-access lookup failed", error.message);
    return json({ error: "No se pudo validar el acceso. Intentá nuevamente." }, 503);
  }

  if (!repairCase || digits(repairCase.insured_phone) !== phone) {
    return json({ error: "No pudimos validar esos datos." }, 401);
  }

  const [{ data: vehicle }, { data: photos, error: photosError }, { data: workshop }] = await Promise.all([
    admin.from("vehicles").select("brand, model, year, plate, color").eq("id", repairCase.vehicle_id).maybeSingle(),
    admin.from("case_photos").select("id, storage_path, caption, created_at").eq("case_id", repairCase.id).order("created_at", { ascending: false }),
    repairCase.workshop_id
      ? admin.from("workshops").select("name, city").eq("id", repairCase.workshop_id).maybeSingle()
      : Promise.resolve({ data: null, error: null }),
  ]);

  if (photosError) {
    console.error("insured-case-access photos lookup failed", photosError.message);
    return json({ error: "No se pudieron cargar las fotos." }, 503);
  }

  const safePhotos = await Promise.all((photos ?? []).map(async (photo: { id: string; storage_path: string; caption: string; created_at: string }) => {
    const { data: signed, error: signedError } = await admin.storage
      .from("case-photos")
      .createSignedUrl(photo.storage_path, 300);
    return {
      id: photo.id,
      caption: photo.caption,
      createdAt: photo.created_at,
      url: signedError ? null : signed?.signedUrl ?? null,
    };
  }));

  return json({
    case: {
      id: repairCase.id,
      claimNumber: repairCase.claim_number,
      status: repairCase.status,
      progress: repairCase.progress,
      description: repairCase.description,
      entryDate: repairCase.entry_date,
      estimatedDeliveryDate: repairCase.estimated_delivery_date,
      vehicle,
      workshop,
      photos: safePhotos,
    },
  });
});

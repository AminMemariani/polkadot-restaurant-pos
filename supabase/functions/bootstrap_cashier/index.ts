// bootstrap_cashier
//
// Provisions a cashier: inserts a row into public.cashiers and writes
// tenant_id / location_id / role into the user's app_metadata so subsequent
// JWTs carry the claims the payments backend uses for authorization.
//
// Caller must be an admin (role='admin' in their own cashiers row) or hold
// the service_role key. Anon access is rejected.
//
// Request:
//   POST /functions/v1/bootstrap_cashier
//   Authorization: Bearer <admin-jwt-or-service-role-key>
//   {
//     "userId": "uuid",            // existing auth.users id
//     "tenantId": "uuid",
//     "locationId": "uuid",
//     "displayName": "Alice",
//     "role": "cashier"             // cashier | manager | admin
//   }
//
// Response: { ok: true, cashier: { ... } }

import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface Body {
  userId: string;
  tenantId: string;
  locationId: string | null;
  displayName: string;
  role: "cashier" | "manager" | "admin";
}

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  // Authorize: caller must hold service-role key OR be an admin cashier.
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.startsWith("Bearer ")
    ? authHeader.slice(7)
    : "";
  if (!token) return json({ error: "unauthenticated" }, 401);

  const isServiceRole = token === SERVICE_ROLE_KEY;
  if (!isServiceRole) {
    const callerClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      global: { headers: { Authorization: authHeader } },
      auth: { autoRefreshToken: false, persistSession: false },
    });
    const { data: caller, error: callerErr } = await callerClient.auth.getUser();
    if (callerErr || !caller.user) return json({ error: "invalid_token" }, 401);

    const { data: callerCashier } = await adminClient
      .from("cashiers")
      .select("role")
      .eq("id", caller.user.id)
      .maybeSingle();
    if (callerCashier?.role !== "admin") {
      return json({ error: "forbidden" }, 403);
    }
  }

  let body: Body;
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  if (
    !body.userId || !body.tenantId || !body.displayName || !body.role ||
    !["cashier", "manager", "admin"].includes(body.role)
  ) {
    return json({ error: "invalid_body" }, 400);
  }

  // Insert/upsert the cashier row.
  const { data: cashier, error: cashierErr } = await adminClient
    .from("cashiers")
    .upsert({
      id: body.userId,
      tenant_id: body.tenantId,
      location_id: body.locationId,
      display_name: body.displayName,
      role: body.role,
    })
    .select()
    .single();

  if (cashierErr) {
    return json({ error: "cashier_upsert_failed", detail: cashierErr.message }, 500);
  }

  // Write claims into app_metadata so they appear in the user's JWT.
  // The payments backend reads tenant_id/location_id/role from these claims.
  const { error: metaErr } = await adminClient.auth.admin.updateUserById(
    body.userId,
    {
      app_metadata: {
        tenant_id: body.tenantId,
        location_id: body.locationId,
        role: body.role,
      },
    },
  );

  if (metaErr) {
    return json({ error: "claims_update_failed", detail: metaErr.message }, 500);
  }

  return json({ ok: true, cashier });
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

// =============================================================================
// GateFlow · Edge Function: admin-create-user
// -----------------------------------------------------------------------------
// Actions (POST body):
//   • Create user (default): email, full_name, role, optional phone/national_id
//   • Reset password:        action = "reset_password", user_id
//
// Creates/resets auth users for parent / bus_driver / guardian. Stamps profile
// with school_id and stores login_email + initial_password for staff to view
// on the user details screen.
// =============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

const ALLOWED_ROLES = ["parent", "bus_driver", "guardian"];

function randomPassword(): string {
  const bytes = new Uint8Array(18);
  crypto.getRandomValues(bytes);
  return btoa(String.fromCharCode(...bytes)).replace(/[^a-zA-Z0-9]/g, "") + "Aa1!";
}

async function verifyStaffCaller(
  admin: ReturnType<typeof createClient>,
  authHeader: string,
  anonKey: string,
  supabaseUrl: string,
) {
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const {
    data: { user: caller },
    error: callerErr,
  } = await callerClient.auth.getUser();

  if (callerErr || !caller) {
    return { error: json({ error: "Invalid or expired session." }, 401) };
  }

  const { data: callerProfile, error: profileErr } = await admin
    .from("profiles")
    .select("role, school_id")
    .eq("id", caller.id)
    .single();

  if (profileErr || !callerProfile) {
    return { error: json({ error: "Caller profile not found." }, 403) };
  }
  if (callerProfile.role !== "school_staff") {
    return { error: json({ error: "Only school staff can manage accounts." }, 403) };
  }
  if (!callerProfile.school_id) {
    return { error: json({ error: "Caller has no school assigned." }, 400) };
  }

  return { caller, callerProfile };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
  const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");
  if (!SUPABASE_URL || !SERVICE_ROLE || !ANON_KEY) {
    return json({ error: "Server is missing Supabase environment variables." }, 500);
  }

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch (_) {
    return json({ error: "Invalid JSON body." }, 400);
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return json({ error: "Missing Authorization header." }, 401);
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const staffCheck = await verifyStaffCaller(
    admin,
    authHeader,
    ANON_KEY,
    SUPABASE_URL,
  );
  if (staffCheck.error) return staffCheck.error;
  const { callerProfile } = staffCheck;

  const action = String(payload.action ?? "create").trim();

  // ---- Reset password ------------------------------------------------------
  if (action === "reset_password") {
    const userId = String(payload.user_id ?? "").trim();
    if (!userId) {
      return json({ error: "user_id is required for reset_password." }, 400);
    }

    const { data: target, error: targetErr } = await admin
      .from("profiles")
      .select("id, role, school_id, login_email")
      .eq("id", userId)
      .single();

    if (targetErr || !target) {
      return json({ error: "User profile not found." }, 404);
    }
    if (target.school_id !== callerProfile!.school_id) {
      return json({ error: "User is not in your school." }, 403);
    }
    if (!ALLOWED_ROLES.includes(target.role)) {
      return json({ error: "Cannot reset password for this role." }, 400);
    }

    const tempPassword = randomPassword();
    const { error: authErr } = await admin.auth.admin.updateUserById(userId, {
      password: tempPassword,
    });
    if (authErr) {
      return json({ error: authErr.message }, 400);
    }

    const { error: profileErr } = await admin
      .from("profiles")
      .update({ initial_password: tempPassword })
      .eq("id", userId);

    if (profileErr) {
      return json({ error: profileErr.message }, 400);
    }

    const { data: authUser } = await admin.auth.admin.getUserById(userId);
    const email = target.login_email ?? authUser?.user?.email ?? null;

    return json({ user_id: userId, email, temp_password: tempPassword }, 200);
  }

  // ---- Create user ---------------------------------------------------------
  const email = String(payload.email ?? "").trim().toLowerCase();
  const fullName = String(payload.full_name ?? "").trim();
  const role = String(payload.role ?? "").trim();
  const phone = payload.phone != null ? String(payload.phone).trim() : null;
  const nationalId =
    payload.national_id != null ? String(payload.national_id).trim() : null;

  if (!email || !fullName || !role) {
    return json({ error: "email, full_name and role are required." }, 400);
  }
  if (!ALLOWED_ROLES.includes(role)) {
    return json({ error: `role must be one of ${ALLOWED_ROLES.join(", ")}.` }, 400);
  }

  const schoolId = (payload.school_id as string) ?? callerProfile!.school_id;
  const tempPassword = randomPassword();

  const { data: created, error: createErr } = await admin.auth.admin.createUser({
    email,
    password: tempPassword,
    email_confirm: true,
    user_metadata: {
      full_name: fullName,
      role,
      school_id: schoolId,
      phone,
      national_id: nationalId,
    },
  });

  if (createErr || !created?.user) {
    const msg = createErr?.message ?? "Failed to create auth user.";
    return json({ error: msg }, 400);
  }

  const newUserId = created.user.id;

  const { error: upsertErr } = await admin
    .from("profiles")
    .update({
      full_name: fullName,
      role,
      school_id: schoolId,
      phone,
      national_id: nationalId,
      login_email: email,
      initial_password: tempPassword,
      is_active: true,
    })
    .eq("id", newUserId);

  if (upsertErr) {
    await admin.auth.admin.deleteUser(newUserId);
    return json({ error: `Profile update failed: ${upsertErr.message}` }, 400);
  }

  return json({ user_id: newUserId, email, temp_password: tempPassword }, 200);
});

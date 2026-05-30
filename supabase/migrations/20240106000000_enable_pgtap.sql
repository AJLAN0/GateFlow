-- =============================================================================
-- GateFlow · Enable pgTAP for SQL-level RBAC / RLS / trigger tests
-- -----------------------------------------------------------------------------
-- pgTAP gives us a SQL test harness (plan/ok/is/throws_ok/...).
-- The extension lives in the `extensions` schema so it can be enabled on the
-- managed Supabase remote without touching the `public` schema.
--
-- All test files in supabase/tests/ wrap their body in BEGIN; ... ROLLBACK; so
-- nothing they do persists in the remote DB.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;

-- =============================================================================
-- Enable pgTAP for SQL-level RLS / trigger tests
-- =============================================================================
-- pgTAP is the standard Postgres testing harness. We install it into the
-- `extensions` schema (Supabase convention) and reference it as
-- `extensions.pgtap` from test files.
--
-- Tests always run inside BEGIN; ... ROLLBACK; so nothing they create
-- persists, even when run against the production database.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;

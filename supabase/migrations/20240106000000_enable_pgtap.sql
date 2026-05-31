-- Enable pgTAP for RLS/RBAC SQL tests (safe; test files use BEGIN/ROLLBACK).
CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;

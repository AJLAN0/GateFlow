#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "==> Tier 1: Dart unit tests (no Supabase required)"
flutter test test/unit/

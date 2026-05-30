#!/usr/bin/env bash
# Tier 1 — fast Dart unit tests. No infra, no secrets.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▶ Tier 1 — flutter test (unit)"
flutter test test/unit "$@"

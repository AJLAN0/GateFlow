#!/usr/bin/env bash
# Tier 1 — Dart unit tests. Runs offline against MockState's demo seed.
# No secrets needed; works in any CI environment.
set -euo pipefail
cd "$(dirname "$0")/.."

exec flutter test test/unit "$@"

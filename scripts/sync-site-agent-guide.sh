#!/usr/bin/env bash
# Sync fee-rights-exchange public agent.md → bankr-tmp-skill tmp-site-agent pack.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/fee-rights-exchange/bankr-app/public/agent.md"
DST="$ROOT/bankr-tmp-skill/tmp-site-agent/agent-guide.md"
if [[ ! -f "$SRC" ]]; then
  echo "Missing source: $SRC" >&2
  exit 1
fi
cp "$SRC" "$DST"
echo "Synced $SRC → $DST"

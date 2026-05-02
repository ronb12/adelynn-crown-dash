#!/bin/bash
# Free CoreSimulator space by erasing device *data* for simulators that are NOT listed
# in scripts/simulator-protect.config. Never runs `simctl erase all`.
#
# Usage:
#   ./scripts/cleanup-simulators-keep-protected.sh          # dry-run (default)
#   ./scripts/cleanup-simulators-keep-protected.sh --execute  # actually erase
#
set -eu
ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$ROOT/simulator-protect.config"
EXECUTE=0
if [ "${1:-}" = "--execute" ]; then EXECUTE=1; fi

if [ ! -f "$CONFIG" ]; then
  echo "Missing $CONFIG"
  echo "Copy scripts/simulator-protect.config.example to scripts/simulator-protect.config"
  echo "and add one protected simulator UUID per line (see scripts/list-simulators.sh)."
  exit 1
fi

PROTECTED_FILE="$(mktemp)"
grep -v '^\s*#' "$CONFIG" | grep -oE '[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}' | tr '[:lower:]' '[:upper:]' | sort -u > "$PROTECTED_FILE"
if [ ! -s "$PROTECTED_FILE" ]; then
  echo "No valid UUIDs in $CONFIG"
  rm -f "$PROTECTED_FILE"
  exit 1
fi

is_protected() {
  U="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
  grep -qxF "$U" "$PROTECTED_FILE"
}

LIST="$(mktemp)"
xcrun simctl list devices | sed -n '/== Devices ==/,$p' > "$LIST"

TO_ERASE="$(mktemp)"
while IFS= read -r line; do
  uid="$(echo "$line" | grep -oE '\([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\)' | tr -d '()' || true)"
  if [ -n "$uid" ]; then
    if ! is_protected "$uid"; then
      echo "$uid" | tr '[:lower:]' '[:upper:]' >> "$TO_ERASE"
    fi
  fi
done < "$LIST"
rm -f "$LIST"

sort -u "$TO_ERASE" -o "$TO_ERASE"
if [ ! -s "$TO_ERASE" ]; then
  echo "Nothing to erase (all listed devices are protected, or no devices found)."
  rm -f "$PROTECTED_FILE" "$TO_ERASE"
  exit 0
fi

N=$(wc -l < "$TO_ERASE" | tr -d ' ')
echo "Protected UUIDs (from $CONFIG):"
cat "$PROTECTED_FILE"
echo ""
if [ "$EXECUTE" -eq 0 ]; then
  echo "Dry-run — would erase $N simulator(s) (device data only):"
  cat "$TO_ERASE"
  echo ""
  echo "Run with --execute to perform erase."
  rm -f "$PROTECTED_FILE" "$TO_ERASE"
  exit 0
fi

xcrun simctl shutdown all 2>/dev/null || true
sleep 1
while IFS= read -r u; do
  [ -z "$u" ] && continue
  echo "Erasing $u ..."
  xcrun simctl erase "$u" 2>/dev/null || echo "  (skip or failed: $u)"
done < "$TO_ERASE"
echo "Done. Protected simulators were not erased."
rm -f "$PROTECTED_FILE" "$TO_ERASE"

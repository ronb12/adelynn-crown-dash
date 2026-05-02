#!/bin/bash
# Free space for Xcode / local builds. Safe: removes only caches, not source.
# Does NOT touch ~/Library/Developer/CoreSimulator (use cleanup-simulators-keep-protected.sh if needed).
set -e
LOG="/tmp/crown-dash-free-space.log"
{
  echo "=== df / ==="
  df -h / 2>/dev/null || true
  echo ""
  echo "=== Before: DerivedData ==="
  du -sh "$HOME/Library/Developer/Xcode/DerivedData" 2>/dev/null || true
  echo ""
  if [[ -d "$HOME/Library/Developer/Xcode/DerivedData" ]]; then
    echo "Clearing ~/Library/Developer/Xcode/DerivedData/* ..."
    rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/*
    echo "Done."
  fi
  echo ""
  echo "=== Optional: iOS device support (old simulators) — large; uncomment in script to remove ==="
  # rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*/Symbols 2>/dev/null || true
  echo ""
  echo "=== npm cache ==="
  if command -v npm >/dev/null 2>&1; then
    npm cache clean --force 2>/dev/null || true
    echo "npm cache cleaned."
  fi
  echo ""
  echo "=== Optional: project node_modules (re-run npm install later) ==="
  PROJECT="$(cd "$(dirname "$0")/.." && pwd)"
  if [[ -d "$PROJECT/node_modules" ]]; then
    SZ=$(du -sh "$PROJECT/node_modules" 2>/dev/null | cut -f1)
    echo "This repo has node_modules (~$SZ). Remove with: rm -rf \"$PROJECT/node_modules\""
  fi
  echo ""
  echo "=== After df / ==="
  df -h / 2>/dev/null || true
} 2>&1 | tee "$LOG"
echo "Log: $LOG"

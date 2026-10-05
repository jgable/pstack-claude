#!/usr/bin/env bash
# Clone or refresh cursor/plugins, resolve the sync range, and print the
# pstack/ diff. Base defaults to the head of the last sync entry in CHANGES.md.
#
#   .claude/skills/sync-upstream/scripts/upstream-diff.sh [head-ref] [base-sha]
#
# Env: PSTACK_UPSTREAM_DIR overrides the clone location (default ~/.cache/pstack-upstream).
set -euo pipefail

repo="$(cd "$(dirname "$0")/../../../.." && pwd)"
clone="${PSTACK_UPSTREAM_DIR:-$HOME/.cache/pstack-upstream}"
head_ref="${1:-origin/main}"
base="${2:-}"

if [ -d "$clone/.git" ]; then
  git -C "$clone" fetch --quiet origin
else
  git clone --quiet https://github.com/cursor/plugins.git "$clone"
fi

if [ -z "$base" ]; then
  # Top sync entry reads "... from `X` (vA) to `Y` (vB)". Y is our base.
  base="$(grep -oE 'to `[0-9a-f]{7,40}`' "$repo/CHANGES.md" | head -1 | grep -oE '[0-9a-f]{7,40}' || true)"
  [ -n "$base" ] || { echo "could not derive base SHA from CHANGES.md; pass it as the second argument" >&2; exit 2; }
fi

head="$(git -C "$clone" rev-parse --short=7 "$head_ref")"
base="$(git -C "$clone" rev-parse --short=7 "$base")"
upstream_version="$(git -C "$clone" show "$head:pstack/.cursor-plugin/plugin.json" | grep -oE '"version": *"[^"]+"' | grep -oE '[0-9][^"]*')"
port_version="$(grep -oE '"version": *"[^"]+"' "$repo/plugins/pstack/.claude-plugin/plugin.json" | grep -oE '[0-9][^"]*')"

echo "clone=$clone"
echo "base=$base"
echo "head=$head"
echo "upstream_version=$upstream_version"
echo "port_version=$port_version"
echo
echo "## upstream commits in range"
git -C "$clone" log --oneline "$base".."$head" -- pstack/
echo
echo "## pstack/ files changed (status<TAB>path)"
git -C "$clone" diff --name-status "$base".."$head" -- pstack/

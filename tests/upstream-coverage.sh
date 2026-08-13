#!/usr/bin/env bash
# Coverage check for an upstream sync: every file upstream added or changed in
# the synced range is either present in the port or on the deliberately-not-
# ported list. Run as:
#   tests/upstream-coverage.sh <upstream-clone> <base-sha> <head-sha>
# where <upstream-clone> is a checkout of cursor/plugins.
set -euo pipefail

[ $# -eq 3 ] || { echo "usage: $0 <upstream-clone> <base-sha> <head-sha>" >&2; exit 2; }
upstream="$1" base="$2" head="$3"
repo="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

# Deliberately not ported (recorded in CHANGES.md): the Cursor manifest, the
# upstream README (frozen copy lives at README-UPSTREAM.md), the docs/ guide,
# and the benny automations.
skip_re='^pstack/(\.cursor-plugin/|README\.md|docs/|automations/)'

while IFS=$'\t' read -r status path; do
  case "$status" in D*) continue ;; esac
  printf '%s' "$path" | grep -qE "$skip_re" && continue
  ported="$repo/plugins/pstack/${path#pstack/}"
  if [ ! -f "$ported" ]; then
    printf 'MISSING: %s (upstream %s) has no ported file at %s\n' "$path" "$status" "${ported#"$repo"/}"
    fail=1
  fi
done < <(git -C "$upstream" diff --name-status "$base".."$head" -- pstack/)

[ "$fail" = 0 ] && echo "ok: every upstream change in $base..$head is ported or deliberately skipped"
exit "$fail"

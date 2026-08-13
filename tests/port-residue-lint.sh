#!/usr/bin/env bash
# Lint the ported tree for Cursor residue an upstream sync can leave behind.
# Each pattern is a left-hand side of the CHANGES.md substitution table; a hit
# means a file was copied from upstream without translation. codex-tools.md is
# the one file that names foreign primitives on purpose (it maps them), and the
# two platform notes legitimately name Codex model slugs.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
tree="$repo/plugins/pstack"
fail=0

hits() { # hits <label> <grep-args...>
  local label="$1"; shift
  local out
  out="$(grep -rnE --exclude-dir=node_modules "$@" 2>/dev/null || true)"
  if [ -n "$out" ]; then
    printf 'FAIL: %s\n%s\n' "$label" "$out"
    fail=1
  else
    printf 'ok: %s\n' "$label"
  fi
}

md=("$tree/skills" "$tree/agents" "$tree/commands" "$tree/hooks" --include=*.md)
no_codex_map=(--exclude=codex-tools.md)

hits "no AskQuestion (must be AskUserQuestion)" \
  '(^|[^r])AskQuestion' "${md[@]}"
hits "no subagent_type: generalPurpose (must be \"general-purpose\")" \
  'generalPurpose' "${md[@]}"
hits "no per-call readonly flag (Claude Code has none)" \
  'readonly' "${md[@]}" "${no_codex_map[@]}" \
  --exclude-dir=typescript-best-practices
hits "no Cursor model slugs" \
  'composer-[0-9]|thinking-xhigh' "${md[@]}"
hits "no ~/.cursor or .cursor/ paths" \
  '\.cursor/' "${md[@]}"
hits "no Task tool references (must be the Agent tool)" \
  'Task (tool|subagent)|\`Task\`' "${md[@]}" "${no_codex_map[@]}"
hits "no Cursor sticky-mode frontmatter on skills" \
  '^(mode|icon|color|reminder):' "${md[@]}"

# gpt-5* slugs (the Cursor-era cross-vendor models): setup-pstack's platform
# note is the one SKILL.md allowed to name Codex examples. gpt-4 in prose
# examples (reflect's synthesizer) is not residue, so the pattern pins gpt-5.
gpt_bad="$(grep -rlE 'gpt-5' "$tree/skills" "$tree/agents" "$tree/commands" \
  --include='*.md' --exclude=codex-tools.md \
  | grep -v 'skills/setup-pstack/SKILL.md' || true)"
if [ -n "$gpt_bad" ]; then
  printf 'FAIL: gpt-* slug outside setup-pstack platform note:\n%s\n' "$gpt_bad"
  fail=1
else
  printf 'ok: gpt-* slugs confined to setup-pstack platform note + codex-tools.md\n'
fi

# Non-markdown assets (ported scripts) must not reach for Cursor paths or the
# upstream package scope. GraphQL endCursor and the deliberate Cursor-Bugbot
# comment detection in watch-pr/github.ts (an external GitHub product, not the
# harness) are not residue, so the pattern pins paths and the package scope.
if [ -d "$tree/skills/poteto-mode/scripts" ]; then
  hits "no cursor paths or package scope in ported scripts" \
    '\.cursor/|@cursor-skill|composer-[0-9]' "$tree/skills/poteto-mode/scripts"
fi

exit "$fail"

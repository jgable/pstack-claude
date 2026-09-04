# NOTICE

This plugin is a port of upstream MIT-licensed work. All upstream copyright notices and license terms are preserved.

## Upstream sources

| Component | Upstream | Copyright | License | License file |
| --- | --- | --- | --- | --- |
| `plugins/pstack/skills/poteto-mode/`, `plugins/pstack/skills/architect/`, `plugins/pstack/skills/arena/`, `plugins/pstack/skills/automate-me/`, `plugins/pstack/skills/figure-it-out/`, `plugins/pstack/skills/how/`, `plugins/pstack/skills/interrogate/`, `plugins/pstack/skills/reflect/`, `plugins/pstack/skills/show-me-your-work/`, `plugins/pstack/skills/tdd/`, `plugins/pstack/skills/typescript-best-practices/`, `plugins/pstack/skills/unslop/`, `plugins/pstack/skills/why/`, `plugins/pstack/skills/principle-*/`, `plugins/pstack/agents/poteto-agent.md` | [cursor/plugins/pstack @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/skills/deslop/` | [cursor/plugins/cursor-team-kit/skills/deslop @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/deslop) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/thermo-nuclear-code-quality-review/` | [cursor/plugins/cursor-team-kit/skills/thermo-nuclear-code-quality-review @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/thermo-nuclear-code-quality-review) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/make-pr-easy-to-review/` | [cursor/plugins/cursor-team-kit/skills/make-pr-easy-to-review @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/make-pr-easy-to-review) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/fix-ci/` | [cursor/plugins/cursor-team-kit/skills/fix-ci @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/fix-ci) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/fix-merge-conflicts/` | [cursor/plugins/cursor-team-kit/skills/fix-merge-conflicts @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/fix-merge-conflicts) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/get-pr-comments/` | [cursor/plugins/cursor-team-kit/skills/get-pr-comments @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/get-pr-comments) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/what-did-i-get-done/` | [cursor/plugins/cursor-team-kit/skills/what-did-i-get-done @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/what-did-i-get-done) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/teach/`, `plugins/pstack/skills/principle-model-the-domain/`, `plugins/pstack/skills/create-verification-skill/`, `plugins/pstack/skills/maintain-verification-skill/` (v0.11.3 additions) | [cursor/plugins/pstack @ 3fe2823](https://github.com/cursor/plugins/tree/3fe2823ce17c1656c222d4b7c59d3f82fbf20143/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/skills/bro/`, `plugins/pstack/skills/no-comments/`, `plugins/pstack/skills/swarm/`, `plugins/pstack/skills/technical-writing/`, `plugins/pstack/agents/comment-sicko.md`, `plugins/pstack/skills/poteto-mode/playbooks/{autopilot-full,autopilot-stack,babysit,orchestrate,shipping,worktree-cleanup}.md`, `plugins/pstack/skills/poteto-mode/references/bugbot-triage.md`, `plugins/pstack/skills/poteto-mode/scripts/`, `plugins/pstack/skills/architect/references/design-red-flags.md`, `plugins/pstack/skills/create-verification-skill/references/feature-map-example/` (v0.13.0–v0.14.0 additions) | [cursor/plugins/pstack @ 99559f2](https://github.com/cursor/plugins/tree/99559f2f52047978602ef365589275831e76af07/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/skills/make-bot-ui/`, `plugins/pstack/docs/guide/`, `plugins/pstack/skills/poteto-mode/scripts/check-plan.mjs` (v0.14.3–v0.14.8 additions) | [cursor/plugins/pstack @ 7314f72](https://github.com/cursor/plugins/tree/7314f723a487ec406b6369fe5865ba034cfed166/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |

## What changed in the port

The port is editorial, not mechanical. See [CHANGES.md](CHANGES.md) for the full per-skill audit of substitutions applied.

Summary of structural changes:

- Plugin content lives at `plugins/pstack/` (with its own `.claude-plugin/plugin.json`). The repo root holds `.claude-plugin/marketplace.json` and the LICENSE / NOTICE / README / CHANGES docs.
- `.claude-plugin/marketplace.json` added at repo root so the repo is installable via `/plugin marketplace add`. The marketplace's single plugin entry sources from `./plugins/pstack`.
- `plugins/pstack/commands/<name>.md` stubs added so each public skill is reachable as a slash command in Claude Code.
- Seven skills imported from `cursor-team-kit`: `deslop`, `thermo-nuclear-code-quality-review`, `make-pr-easy-to-review`, `fix-ci`, `fix-merge-conflicts`, `get-pr-comments`, `what-did-i-get-done`. All copied verbatim — no rewiring needed.
- `plugins/pstack/skills/babysit/` began as an independently authored Claude Code analog of Cursor's `/babysit` built-in. Since the v0.14.0 sync it is a thin port-authored router; the babysit protocol itself is upstream-derived and lives at `plugins/pstack/skills/poteto-mode/playbooks/babysit.md` (attributed in the table above).
- A Codex build shares the same `skills/` tree. It adds `plugins/pstack/.codex-plugin/plugin.json`, a root `.agents/plugins/marketplace.json`, and `plugins/pstack/skills/poteto-mode/references/codex-tools.md` (the Claude-to-Codex tool, model, and built-in map), plus a one-line Platform note in the skills that name a Claude primitive. The skill content itself is unchanged. See [CHANGES.md](CHANGES.md#codex-port).

## Modifications

Per the MIT license, modifications are permitted. Skill bodies have been edited to substitute Cursor-specific primitives with their Claude Code equivalents (the full substitution table is in [CHANGES.md](CHANGES.md)). All upstream copyright notices in source files (where present) are preserved.

Files authored for this port (not derived from upstream):

- `plugins/pstack/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json` (repo root)
- `plugins/pstack/.codex-plugin/plugin.json`
- `.agents/plugins/marketplace.json` (repo root)
- `plugins/pstack/skills/poteto-mode/references/codex-tools.md`
- `plugins/pstack/commands/*.md`
- `plugins/pstack/skills/babysit/SKILL.md` (port-authored router; the protocol it routes to is upstream-derived, see the table above)
- `tests/skill-collision-repro.sh`, `tests/port-residue-lint.sh`, `tests/upstream-coverage.sh`
- `NOTICE.md` (this file)
- `README.md`
- `CHANGES.md`
- `LICENSE-cursor-team-kit` (copied verbatim from upstream cursor-team-kit MIT)

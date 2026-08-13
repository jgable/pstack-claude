# pstack for Claude Code, Codex, and Prime Agent

Claude Code port of [poteto](https://x.com/poteto)'s [pstack](https://github.com/cursor/plugins/tree/main/pstack) plugin (skill tree synced against upstream `99559f2`, pstack v0.14.0; upstream reviewed through `424829e`, docs-only — see [What's deliberately not ported](#whats-deliberately-not-ported)). The same `skills/` tree also ships as a Codex plugin (see [Running on Codex](#running-on-codex)) and is discovered as-is by [Prime Agent](https://github.com/PrimeIntellect-ai/prime-agent) (see [Prime Agent](#prime-agent)). Original by Lauren Tan; ships MIT. Imports seven skills from [cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit) (also MIT): `deslop`, `thermo-nuclear-code-quality-review`, `make-pr-easy-to-review`, `fix-ci`, `fix-merge-conflicts`, `get-pr-comments`, `what-did-i-get-done`.

> if you want to go fast, go deep first. pstack helps you write less, but higher quality code. rigorous agent workflows you can parallelize with confidence.

This is not a verbatim copy. Skill bodies have been edited so every Cursor-specific primitive resolves to its Claude Code equivalent — see [Differences from upstream](#differences-from-upstream) for the full list. The exhaustive per-skill audit lives in [CHANGES.md](CHANGES.md); license attribution lives in [NOTICE.md](NOTICE.md); the upstream README is preserved verbatim at [README-UPSTREAM.md](README-UPSTREAM.md).

## Install

### Claude Code

This repo ships as a Claude Code marketplace containing one plugin (`pstack`).

```shell
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

The plugin no longer ships a SessionStart auto-fire hook (0.9.5–0.9.10 injected a poteto-mode mandate every session; 0.10.0 removed it so routing stays opt-in). To restore the always-on routing, add a user-level hook: put your mandate text in a file (the retired plugin mandate at `plugins/pstack/hooks/session-start-context.md`, last present in 0.9.10, is a good starting point) and register it in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [{ "type": "command", "command": "cat ~/.claude/pstack-mandate.md" }]
      }
    ]
  }
}
```

A SessionStart hook's stdout is injected as session context, so `cat` is the whole mechanism.

### Codex

The same plugin carries a `.codex-plugin/plugin.json` manifest and a root `.agents/plugins/marketplace.json`. The verified install is to link the plugin's skills into your cross-runtime skills directory:

```shell
git clone https://github.com/michael-denyer/pstack-claude
cd pstack-claude
for s in plugins/pstack/skills/*/; do ln -s "$PWD/$s" ~/.agents/skills/"$(basename "$s")"; done
```

Codex discovers the linked skills and namespaces them under the plugin, so they list as `pstack:poteto-mode`, `pstack:tdd`, and so on. The namespace comes from `plugins/pstack/.codex-plugin/plugin.json` and resolves through the flat symlinks, even though each linked skill sits one directory below that manifest (verified on a live session via this symlink install). To enable the multi-model and parallel-subagent skills (`interrogate`, `arena`, `how`, `why`, `reflect`, `architect`), turn on subagents in `~/.codex/config.toml`:

```toml
[features]
multi_agent = true
```

For slash-command shortcuts (`/poteto-mode`, `/tdd`, and the rest), link the command files into Codex's prompts directory:

```shell
mkdir -p ~/.codex/prompts
for c in plugins/pstack/commands/*.md; do ln -s "$PWD/$c" ~/.codex/prompts/"$(basename "$c")"; done
```

Each command invokes its skill, so `/tdd` runs the `tdd` skill. Installing the full plugin through the Codex marketplace (the root `.agents/plugins/marketplace.json`) carries skills and commands together; the two symlink steps above are the verified local path. Teardown is `rm ~/.agents/skills/<name>` and `rm ~/.codex/prompts/<name>.md`.

### Prime Agent

[Prime Agent](https://github.com/PrimeIntellect-ai/prime-agent) discovers skills from `~/.agents/skills/` and from `.agents/skills/` in the working tree up to the git root ([docs](https://github.com/PrimeIntellect-ai/prime-agent/blob/main/packages/coding-agent/docs/skills.md)). That is the same `~/.agents/skills/` directory the Codex install symlinks into, so the [Codex skill-link step](#codex) doubles as the Prime install — if you have already run it, Prime picks the skills up with no extra work:

```shell
git clone https://github.com/michael-denyer/pstack-claude
cd pstack-claude
for s in plugins/pstack/skills/*/; do ln -s "$PWD/$s" ~/.agents/skills/"$(basename "$s")"; done
```

pstack's `SKILL.md` frontmatter is a subset of what Prime reads: it requires `name` (lowercase, matching the parent directory — every pstack skill already conforms) and `description`, honours `disable-model-invocation`, and ignores unknown keys such as pstack's `user-invocable`. `curl -fsSL https://app.primeintellect.ai/prime-agent/install.sh | sh` installs Prime itself; `--no-skills` disables discovery, and explicit `--skill <path>` still loads. Prime is model-agnostic, so running these skills against **ChatGPT / OpenAI models is a Prime backend setting, not a plugin change** — keep the multi-model panels in `arena`, `interrogate`, `architect`, and `how` genuinely diverse across whatever models you configure (see the OpenAI panel note under [Running on Codex](#running-on-codex)).

Unverified relative to Codex: the Codex path above is confirmed on a live session; the Prime path is derived from Prime's documented discovery paths and frontmatter schema, not yet run on a live Prime session. The plugin ships no auto-fire hook, so enter `pstack:poteto-mode` by name or add a standing routing instruction to your Prime config. Teardown is `rm ~/.agents/skills/<name>`.

## Layout

```text
.
├── .claude-plugin/marketplace.json   # Claude Code marketplace manifest (repo root)
├── .agents/plugins/marketplace.json  # Codex marketplace manifest (repo root)
├── plugins/pstack/                   # the plugin itself
│   ├── .claude-plugin/plugin.json    # Claude Code manifest
│   ├── .codex-plugin/plugin.json     # Codex manifest (skills: ./skills/)
│   ├── skills/                       # 52 skills (shared by all three runtimes)
│   │   ├── poteto-mode/references/codex-tools.md  # Claude→Codex tool/model/skill map
│   │   └── poteto-mode/scripts/      # watch-pr, orch, worktree-audit (bun; used by the 0.14 playbooks)
│   ├── commands/                     # 31 slash command stubs (Codex-compatible; link into ~/.codex/prompts)
│   └── agents/                       # Claude subagents: poteto-agent, comment-sicko (Codex routes via codex-tools.md)
├── tests/skill-collision-repro.sh    # flag/version/quad invariants (--static-only needs no CLI)
├── tests/port-residue-lint.sh        # greps the tree for untranslated Cursor primitives
├── tests/upstream-coverage.sh        # checks a sync range is fully ported or deliberately skipped
├── LICENSE                           # pstack upstream MIT
├── LICENSE-cursor-team-kit           # cursor-team-kit upstream MIT
├── NOTICE.md                         # attribution table
├── CHANGES.md                        # per-skill substitution audit
└── README.md                         # this file
```

Plugin-internal path references in the docs below (`skills/<name>/`, `commands/<name>.md`) are relative to `plugins/pstack/`.

## Running on Codex

The Codex build shares one `skills/` tree with the Claude Code build. Nothing is forked or generated. One mapping file does the translation. That single-mapping-file spine is the one `superpowers` ships for Codex. pstack diverges in one respect. superpowers writes its skills in tool-neutral language, so no skill names a runtime tool. pstack keeps the upstream Claude-native prose and adds a one-line Platform note to each skill that names a Claude primitive, so the port stays in lockstep with upstream sync.

- **Skill invocation.** Codex loads `SKILL.md` natively. There is no `Skill` tool. You invoke a skill by name (ask for it, or pick `pstack:poteto-mode` from the list).
- **Commands.** The 31 `commands/*.md` files are Codex-compatible as written. Codex reads their `description` frontmatter and the filename and ignores the keys it doesn't know (`name`, `disable-model-invocation`), and each body invokes its skill. They surface as slash commands when the full plugin is installed, or you can link them into `~/.codex/prompts/` for `/name` shortcuts (see [Install on Codex](#codex)). The `disable-model-invocation: true` flag exists for Claude Code, where a command and a skill sharing a name collide: the Skill tool resolved the name to the command trampoline, which told the model to invoke the skill, which resolved to the trampoline again — the skill never loaded (see CHANGES 0.9.7). With the flag, the model's Skill tool reaches only the skill; user-typed `/pstack:<name>` still runs the command. The mirror rule: a skill with a same-named command must **not** carry the flag — on a skill it makes the Skill tool refuse the invocation entirely, which broke the SessionStart mandate and every trampoline body until CHANGES 0.9.8 removed it from the 12 skills that had it. Only the command-less `principle-*` leaves keep the flag.
- **Tool, model, and built-in mapping.** When a skill names a Claude tool (the `Agent` tool, `AskUserQuestion`), a `claude-*` model slug, or a Claude built-in skill (`run`, `verify`, `loop`, `plugin-dev:skill-development`), it resolves through [`skills/poteto-mode/references/codex-tools.md`](plugins/pstack/skills/poteto-mode/references/codex-tools.md). `poteto-mode` and every skill that names one of those carries a one-line **Platform note** pointing there.
- **Subagents.** The `Agent` tool maps to Codex `spawn_agent` / `wait_agent` / `close_agent`, enabled by `multi_agent = true`. Parallel fan-out is multiple `spawn_agent` calls in one turn. Without the flag, `interrogate`, `arena`, `how`, `why`, `reflect`, and `architect` degrade to a single sequential pass. There is no `poteto-agent` subagent type on Codex; route ad-hoc subagents by dispatching a `spawn_agent` told to read `poteto-mode` first.
- **Auto-fire.** The plugin ships no SessionStart hook (removed in 0.10.0). On Claude Code, add the user-level hook from [Install](#claude-code) for always-on routing; on Codex, enter `pstack:poteto-mode` by name or add a standing instruction to `~/.codex/AGENTS.md`.
- **Models.** The `claude-*` slugs in skills are Claude defaults. On Codex substitute your configured Codex models, keeping multi-model panels genuinely diverse. `/setup-pstack` writes `~/.codex/pstack-models.md` (referenced from `~/.codex/AGENTS.md`) with Codex slugs instead of `~/.claude/pstack-models.md`.

Verified on a live Codex session installed via the symlinks: the user-facing skills are discovered and namespaced under `pstack` (`pstack:poteto-mode`, `pstack:interrogate`, and so on). The `principle-*` leaf skills carry `disable-model-invocation: true` and no command, so Codex does not surface them in the picker, the same as Claude Code. They stay installed for `poteto-mode` to read by path. The deeper behaviors (mapping resolution mid-task, `spawn_agent` fan-out) follow the proven `superpowers` pattern and are worth confirming in your own session.

## Dependencies

Nothing is declared in `plugin.json`. Install the one companion plugin yourself:

- **`plugin-dev`** (from the `claude-plugins-official` marketplace) — the rewiring routes skill-authoring tasks (in `automate-me`, `reflect`, `poteto-mode`) to the `plugin-dev:skill-development` skill:

  ```shell
  /plugin marketplace add anthropics/claude-plugins-official
  /plugin install plugin-dev@claude-plugins-official
  ```

  Until 0.9.2 this was a `dependencies` entry in `plugin.json`. The desktop app's `--plugin-dir` load mode can never resolve cross-marketplace dependencies and hard-disables the whole plugin, so 0.9.3 removed the declaration — full mechanism in the 0.9.3 entry of [CHANGES.md](CHANGES.md). Without `plugin-dev` installed, only the skill-authoring routes degrade; everything else works.

Not declared as deps, but referenced in skill bodies:

- **`run`, `verify`, `loop`** — Claude Code CLI built-ins (ship with the binary, always available).
- **`bun`** — runtime for `skills/poteto-mode/scripts/` (the `watch-pr` PR watcher and `orch` store the 0.14 playbooks call). Only needed when a playbook reaches for those scripts.
- **`gh` CLI** — system-level requirement of the babysit workflow and the `watch-pr` script. Install via [`brew install gh`](https://cli.github.com) and authenticate with `gh auth login`.

No third-party plugins. The harsher-critique escape hatch lives in the bundled `thermo-nuclear-code-quality-review` skill (imported from cursor-team-kit), not in an external plugin.

## Slash commands

| command | use it when |
| --- | --- |
| `/poteto-mode` | default entry point for any non-trivial task |
| `/how` | walk through how a subsystem works |
| `/why` | investigate why something was built this way (parallel multi-MCP evidence) |
| `/architect` | settle types and module shape before writing code that crosses a function boundary |
| `/arena` | run N parallel attempts at the same task and pick the best parts |
| `/interrogate` | have four different models try to break a diff |
| `/automate-me` | draft your own personal -mode skill from recent transcripts |
| `/reflect` | capture a long task's lessons as a skill edit |
| `/tdd` | fix a bug by writing the failing test first, then the fix |
| `/typescript-best-practices` | ground type-system discipline in TypeScript syntax |
| `/figure-it-out` | design a rigorous, auditable playbook for a task no bundled playbook fits |
| `/show-me-your-work` | log decisions to a reviewable tsv decision trail |
| `/blast-radius` | find what a change could break beyond the diff and prove safety by running code |
| `/recall` | catch up on recent working context from chat history, live state, and the shared record |
| `/setup-pstack` | configure pstack per-role model choices |
| `/unslop` | clean up writing by removing AI tells |
| `/deslop` | deslop a diff before commit |
| `/babysit` | drive a PR or stack to merge-ready in a declared mode (drive, background, threads-only, check) |
| `/swarm` | fan out N parallel workers over slices or races and get one report |
| `/no-comments` | spawn Comment Sicko, then act on the accepted findings |
| `/technical-writing` | apply the layered technical-writing standard to docs and prose |
| `/bro` | restate the last message in plain language |
| `/thermo-nuclear-code-quality-review` | extremely strict maintainability audit |
| `/make-pr-easy-to-review` | clean noisy history and improve PR description before review |
| `/fix-ci` | find failing PR checks, inspect logs, apply focused fixes |
| `/fix-merge-conflicts` | non-interactively resolve merge conflicts, validate, finalize |
| `/get-pr-comments` | fetch and summarize review comments from the active PR |
| `/what-did-i-get-done` | summarize authored commits over a user-chosen period |

## Subagents

`poteto-agent` ships unchanged. Spawn from a parent with `subagent_type: "poteto-agent"`. Upstream 0.14's `is_background: true` frontmatter is not carried — Claude Code expresses that per call (`run_in_background: true`), which `poteto-mode` already states as the default for every `Agent` call.

`comment-sicko` (new in upstream 0.13.0) is the comment-hating reviewer the `no-comments` skill spawns with `subagent_type: "comment-sicko"`. Its upstream `name: Comment Sicko` is kebab-cased because in Claude Code the agent name is the `subagent_type` identifier.

## Differences from upstream

The port is editorial, not mechanical. Anywhere upstream pstack assumed Cursor-specific primitives, this port substitutes the Claude Code equivalent so refs actually resolve. Two prior ports ([v1truv1us/ai-eng-system](https://github.com/v1truv1us/ai-eng-system), [Evan-Kim2028/agent-fleet](https://github.com/Evan-Kim2028/agent-fleet)) stop at namespacing — they vendor pstack under `pstack/` and leave the Cursor refs intact. This port does the content surgery.

### What's added

- **`skills/babysit/`** — the `/babysit` entry point. Originally an independently authored analog of Cursor's closed-source built-in; since the v0.14.0 sync it is a thin router into the ported upstream protocol at `skills/poteto-mode/playbooks/babysit.md` (upstream published its real babysit playbook in 0.14, so the blind analog retired rather than compete with it).
- **`skills/deslop/`** — imported verbatim from `cursor-team-kit`. Cleans AI tells out of diffs before commit.
- **`skills/thermo-nuclear-code-quality-review/`** — imported verbatim from `cursor-team-kit`. Used as the harsher-critique escape hatch in `arena`, `interrogate`, `architect`, and `how` (replaces the Cursor-original cross-vendor bridge).
- **`skills/make-pr-easy-to-review/`** — imported verbatim from `cursor-team-kit`. Composes with `opening-a-pr` and `babysit`.
- **`skills/fix-ci/`** — imported verbatim from `cursor-team-kit`. Narrower CI-fix primitive that `babysit` can route to.
- **`skills/fix-merge-conflicts/`** — imported verbatim from `cursor-team-kit`. Pairs with `babysit` step 5.
- **`skills/get-pr-comments/`** — imported verbatim from `cursor-team-kit`. Primitive for `babysit` step 4 and `reflect`.
- **`skills/what-did-i-get-done/`** — imported verbatim from `cursor-team-kit`. Commit summary over a chosen period.

### What's substituted in skill bodies

| Upstream (Cursor) | This port (Claude Code) |
| --- | --- |
| `Task` tool, `subagent_type: generalPurpose`, `readonly: false/true` | `Agent` tool, `subagent_type: "general-purpose"`, no readonly flag (subagent_type controls MCP access) |
| `AskQuestion` tool | `AskUserQuestion` tool |
| Cursor's built-in `/loop` | Claude Code's built-in `loop` skill |
| Cursor's built-in `/babysit` | `babysit` skill routing to the ported Babysit playbook (`poteto-mode/playbooks/babysit.md`) |
| Cursor's built-in `/loop` dynamic mode | the `loop` skill with no interval (model self-paces) |
| `environment: "cloud"` on agent spawns | `isolation: "worktree"` locally; `isolation: "remote"` where available |
| `is_background: true` agent frontmatter | dropped; `run_in_background: true` is the stated default per `Agent` call |
| Cursor agent store / dashboard liveness | session scratchpad directory / background-agent completion notifications |
| Cursor's built-in `/create-skill` | `plugin-dev:skill-development` skill |
| `cursor-team-kit` `control-cli` (CLI/TUI driver) | Claude Code's `run` skill |
| `cursor-team-kit` `control-ui` (browser/Electron driver) | Claude Code's `verify` skill |
| Transcripts at `~/.cursor/projects/*/` or `agent-transcripts/` | `~/.claude/projects/<encoded-cwd>/*.jsonl` (where `<encoded-cwd>` is the workspace cwd with `/` → `-`) |
| Skill paths `.cursor/skills/`, `~/.cursor/plugins/` | `.claude/skills/`, `~/.claude/plugins/` |
| MCP discovery via Cursor's `mcps/` directory | Tool list at top of system prompt (`mcp__<server>__<name>` entries), or `.mcp.json`, or `claude mcp list` |
| Model `composer-2.5-fast` (Cursor) | `claude-sonnet-4-6` |
| Model `claude-opus-4-X-thinking-xhigh` (Cursor UI variant) | `claude-opus-4-8` (extended thinking configured separately) |
| Models `gpt-5.3-codex-high-fast`, `gpt-5.5-high-fast` (via Cursor) | `claude-sonnet-4-6`, `claude-haiku-4-5` (Claude family) |
| Multi-model panels (arena, architect, interrogate, how-critics) | Default quad is `claude-opus-5` + `claude-fable-5` + `claude-opus-4-6` + `claude-sonnet-5` — four distinct models across tiers and generations (replaces the cross-vendor diversity lost in translation and restores upstream's four-way split). |

### What's lost in translation

**Cross-vendor model diversity.** `arena`, `interrogate`, `architect`, and `how` all rely on stress-testing a design against four *different* model families. Claude Code is single-vendor, so the four-way split collapses to four Claude variants by tier and thinking budget. Instead of bridging to an external CLI for that diversity, the rewiring routes the "harsher pass" to the bundled `thermo-nuclear-code-quality-review` skill — different style of pressure (strict maintainability rubric), not vendor diversity, but it lives in-plugin with no extra installs.

### What's deliberately kept

- The `poteto-agent` subagent ID and all references to it.
- `run_in_background: true` on Agent calls (Claude Code supports it).
- `/loop`, `/deslop`, `/babysit` slash references in skill bodies — they all resolve in Claude Code now.
- The principle/playbook structure and every word of the principles themselves.

### What's deliberately not ported

- **`docs/guide/`** (upstream 0.12.0–0.14.0) — upstream's ten-chapter user guide with screenshots. It documents the Cursor experience (sticky modes, cloud agents, the Cursor dashboard) and duplicates what this README and CHANGES.md already cover for Claude Code. Revisit if the port grows its own guide.
- **`agents/poteto-agent.md` `is_background: true`** (upstream 0.14.0) — Claude Code agent frontmatter has no such key; the behavior is the port's stated per-call default (`run_in_background: true`).
- **`automations/benny/`** (upstream `0452e08`, the only pstack change between `e46364b` and v0.10.0) — a dormant Slack issue-triage and reproduce-and-fix automation pack built on Cursor's event-triggered automations. It registers no slash skills even upstream, so excluding it changes nothing about the ported plugin's behavior. Porting it would mean translating Cursor's event-trigger runtime to Claude Code's polling-based scheduled agents plus Slack and tracker plumbing — speculative infrastructure with no local user. Revisit if an unattended issue-intake stream materialises; the likely first step is porting the triage skill onto a single Claude scheduled agent, not the whole pack.
- **`cursor-team-kit` beyond the seven imported skills** — the rest either duplicate Claude Code built-ins (`verify-this` → the `verify` skill and built-in verification discipline; `check-compiler-errors` → LSP diagnostics; `control-cli`/`control-ui` → `run`/`verify`, already the substitution targets) or overlap skills this port ships (`loop-on-ci`, `review-and-ship`, `weekly-review` vs `babysit`, `fix-ci`, `make-pr-easy-to-review`, `what-did-i-get-done`). `pr-review-canvas` is Cursor-UI-specific.

### Forking note

Editing skill bodies forks this from upstream. Re-syncing to a future pstack release means re-applying the substitution table. The full re-port recipe is in [CHANGES.md](CHANGES.md).

## License

MIT. Two upstream LICENSE files are preserved:

- [LICENSE](LICENSE) — pstack (Lauren Tan)
- [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) — Cursor (covers the `deslop` and `thermo-nuclear-code-quality-review` skills)

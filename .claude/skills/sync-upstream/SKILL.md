---
name: sync-upstream
description: Pull the latest cursor/plugins pstack changes into this Claude Code port. Use for /sync-upstream, "sync upstream", "catch up with upstream pstack", or "port upstream vX.Y.Z".
---

# Sync the port to upstream pstack

This repo is an editorial port of `cursor/plugins/pstack`. A sync copies upstream's changes into `plugins/pstack/`, translates Cursor primitives to Claude Code ones, records the work in the three docs, bumps three manifests, and proves coverage with the scripts in `tests/`.

Read first, in this order:

1. The top sync entry in `CHANGES.md`. It is the template for the entry you will write and shows the current policy on model slugs and skipped files.
2. The "Substitution table" section of `CHANGES.md`. Every Cursor primitive you meet in upstream text has a row there. If you meet one that does not, add a row.
3. "What's deliberately not ported" in `README.md`.

## 1. Resolve the range, then branch

Run the helper. It refreshes a clone at `~/.cache/pstack-upstream`, takes the base SHA from the top `CHANGES.md` sync entry, and prints the commits and changed files under `pstack/`:

```bash
.claude/skills/sync-upstream/scripts/upstream-diff.sh            # base from CHANGES.md, head = origin/main
.claude/skills/sync-upstream/scripts/upstream-diff.sh 2cbf585    # pin a head SHA (upstream has no tags)
```

Then start from latest `main` and branch as `jgable/<MM-DD>-sync-upstream-v<upstream_version>`, using today's date and the `upstream_version` the helper printed:

```bash
git checkout main && git pull --ff-only
git checkout -b jgable/10-05-sync-upstream-v0.15.0
```

Keep `clone`, `base`, and `head` from the helper output. If the file list is empty, say so and stop. If upstream only touched `pstack/README.md` or `assets/`, refresh `README-UPSTREAM.md` and stop. Do not bump the version for a docs-only upstream change.

## 2. Classify every changed file

Walk the status list once and bucket each path. Write the buckets into the session scratchpad before editing anything, so the CHANGES entry can be written from them.

- **Added skill or playbook.** Will be copied and translated. Note whether upstream pairs it with a command. Public skills need a `commands/<name>.md` trampoline.
- **Modified file the port carries.** Diff upstream's base and head versions, then apply those hunks to the ported file by hand. Never overwrite the ported file with upstream's copy. The port's earlier translations live in it.
- **Deleted upstream.** Delete the ported counterpart unless the port depends on it. Record either way.
- **Skip.** Matches the skip regex in `tests/upstream-coverage.sh`, or is pure Cursor model-slug churn, or is a Cursor-only surface with no Claude analog. Each skip needs one sentence of reason in CHANGES.

Show the buckets to the user as a short table before the edit pass.

## 3. Apply and translate

For each added or modified file:

- Copy or merge the upstream text, then walk the substitution table against it. The common ones: `Task` becomes `Agent`, `generalPurpose` becomes `"general-purpose"`, `readonly:` flags are dropped and restated as a `subagent_type` choice, `AskQuestion` becomes `AskUserQuestion`, `environment: "cloud"` becomes `isolation: "worktree"` plus `run_in_background: true`, Cursor paths become `.claude/` paths, Cursor model slugs become the port's workhorse or panel quad.
- Leave upstream's `disable-model-invocation: true` off any skill that has a command trampoline. On a command-paired skill the flag makes the Skill tool refuse the call. The command carries the flag instead.
- `principle-*` leaves keep `user-invocable: false`.
- A new agent file's `name` must equal its filename stem. That name is the `subagent_type`.
- New scripts under `skills/*/scripts/` get run once locally. Record the command and result for the CHANGES entry.

Do this in one pass, by hand or with a single delegate. Do not fan out per file, because translations interact, such as a playbook that names a skill you are also renaming.

## 4. Record

- **`CHANGES.md`.** New top entry `## <port version> — sync to upstream v<upstream version>`. First paragraph names the range with both SHAs and the skill and command counts before and after. Then: new skills, content refinements over existing translations, model strategy decision, residue sweep, tests run, deliberately not ported. Match the voice of the entry above it.
- **`NOTICE.md`.** One new row in the upstream sources table listing the new upstream-derived paths pinned at the head SHA.
- **`README.md`.** Update "What's added" for new skills, the substitution table for new rows, and "What's deliberately not ported" for new skips.
- **`README-UPSTREAM.md`.** Replace with upstream's `pstack/README.md` at the head SHA.
- **Manifests.** Bump the same version string in `plugins/pstack/.claude-plugin/plugin.json`, `plugins/pstack/.codex-plugin/plugin.json`, and `.claude-plugin/marketplace.json`. Patch bump for a sync with no new skills, minor bump otherwise.
- **`tests/upstream-coverage.sh`.** If you added a skip category, extend its `skip_re` and its comment.

## 5. Prove it

Run all three and paste the last line of each into your report:

```bash
tests/skill-collision-repro.sh --static-only
tests/port-residue-lint.sh
tests/upstream-coverage.sh "$clone" "$base" "$head"
```

A `MISSING:` line from the coverage script means a file is neither ported nor on the skip regex. A `FAIL:` from the residue lint means a Cursor primitive survived translation. Fix the file, not the test, unless the skip is a recorded decision.

Count skills and commands and confirm they match the numbers in the CHANGES entry:

```bash
ls plugins/pstack/skills | wc -l; ls plugins/pstack/commands | wc -l
```

## 6. Review, then commit

Open a Plannotator review of the uncommitted worktree with the `plannotator-review` skill and wait for Jacob's annotations. Address every annotation in the same session, rerun the three tests if a file under `plugins/pstack/` changed, then review again if the fixes were more than wording.

Commit only after the review comes back with no open annotations. Follow the `jg-commit-format` skill: a conventional title such as `feat(pstack): sync port to upstream v0.15.0 (0.11.0)`, then Why?, Changes, and Testing sections. The Testing section lists the three test commands and their last lines, and an install user flow.

Report: the range, the bucket table with outcomes, the three test results, and anything you skipped with its reason. Include the install check the previous sync used: `/plugin marketplace update pstack-claude`, then `/plugin update pstack@pstack-claude`, then confirm the version in a new session.

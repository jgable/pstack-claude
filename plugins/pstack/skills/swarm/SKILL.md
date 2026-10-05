---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
---

# Swarm

Fan out N parallel workers. They may cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report.

**Platform note.** On Codex or another non-Claude runtime, the Claude tool names, `claude-*` slugs, and Claude built-in skills named below are Claude defaults. Resolve them via [`codex-tools.md`](../poteto-mode/references/codex-tools.md).

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Set N from the user or derive it from the shape. N is total workers, not how many run at once. Background workers share the user's machine, so stage a wide partition in waves instead of spawning dozens at once.
4. Pick the worker model from the `swarm workers` line in `~/.claude/pstack-models.md`. If the file or that line is missing, use `claude-opus-4-8`. A wide swarm of mechanical slices can drop to your fast code model. For `auto` or `inherit-parent`, omit `model` so the workers run on the parent model. If the `Agent` tool rejects a slug, use the default and say so. If it rejects the default, use the closest valid slug of the same family from its error message. For a model race, name each arm's model up front.
5. Give each worker its own writable output when it writes. Use `isolation: "worktree"`, a branch, or `/tmp/swarm-<slug>/worker-<n>/`. N workers writing one path is shared mutable state and fails the **separate-before-serializing-shared-state** principle skill test. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Spawn all N workers in one message with the `Agent` tool, `subagent_type: "poteto-agent"`, `run_in_background: true`, and the step 4 model, left unset for `auto` or `inherit-parent`. Add `isolation: "worktree"` for any worker that writes files, so the workers never edit each other's tree.

`isolation: "remote"` runs a worker on a detached cloud machine instead. It is availability-gated, so reach for it only when the user has it and the work genuinely belongs off this machine.

Worktrees branch from the parent's HEAD, and the `Agent` tool takes no base-branch argument. When the workers must start from a non-default branch, check that branch out in the parent before spawning.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Drain before you aggregate. Wait for every worker's completion notification and read its terminal result. A worker still running has no result yet, so never write one on its behalf.

Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

Keep a compact result table, one-line evidenced issues, and explicit gaps or dropouts.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.

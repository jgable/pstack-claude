---
name: babysit
description: Drive a PR or a stack to merge-ready in a declared mode (drive, background, threads-only, check), working conflicts, review threads, and CI. Use for "babysit this", "get it green", "merge-ready", "watch CI", "address the bugbot comments", or "check on PR X".
---

# Babysit a PR

The protocol lives in the poteto-mode Babysit playbook, [`../poteto-mode/playbooks/babysit.md`](../poteto-mode/playbooks/babysit.md). Read it in full and follow it. Map the user's request to one of its modes first, and declare that mode in your first line before any poll: `drive` for "babysit this" / "get it green" / "merge-ready", `background` for triage while a plan is still executing, `threads-only` for "address the bugbot comments", `check` for "check on X" / "is it green". The playbook's step 1 owns the mapping, its Bugbot triage runs against [`../poteto-mode/references/bugbot-triage.md`](../poteto-mode/references/bugbot-triage.md), and landing a stack is a different playbook (`../poteto-mode/playbooks/shipping.md`), which needs an explicit request to merge or ship.

**Platform note.** The playbook names Claude tool and built-in skill names (the `loop` skill, `isolation`, `run` and `verify`). On Codex or another non-Claude runtime, resolve them via [`codex-tools.md`](../poteto-mode/references/codex-tools.md).

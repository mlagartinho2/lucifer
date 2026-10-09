# Lucifer — Copilot instructions

Lucifer is an in-house coding agent (functional equivalent of GitHub Copilot) on org-hosted models behind one OpenAI-compatible Gateway. CLI-first, Linux-only sandbox hosts, one dedicated VM per session. Target repos are always git repos.

The project constitution is `.specify/memory/constitution.md`. This file is the day-to-day version of it. If they ever differ, the constitution and the spec win.

## Where things live
- Spec, split by section: `docs/spec/NN-*.md` (currently v0.69). **This is a read-only mirror** of the source repository; do not edit it. If the spec needs a change, say so and stop.
- Resolution status and real values: `LUCIFER_IMPLEMENTATION_CHECKLIST_v1.md` (C1–C59).
- Build plan: `BUILD_ORDER.md` (Steps 0–12, one per Spec Kit feature).
- Spec Kit: `.specify/` (constitution, templates, scripts) and the `/speckit-*` skills in `.github/skills/`.
- Code goes in `lucifer/`, tests in `tests/`.
- There is no `archive/` here. Never look for or use stale material.

## Context discipline (important)
- Do NOT load `docs/spec/_preamble-and-changelog.md` (~148 KB) or `docs/spec/13-*.md` (~152 KB) whole. Do not load other large spec files whole either (`06-tool-set.md` ~60 KB, `09-retrieval-indexing.md` ~54 KB, `03-agent-execution-loop.md` ~49 KB): read the section you are building.
- Load only the section being built plus `docs/spec/00-component-map.md`.
- Search the checklist with grep (`grep -n 'C21' LUCIFER_IMPLEMENTATION_CHECKLIST_v1.md`) instead of reading it whole.
- "Resolved (vX.Y)" notes are authoritative. If a later note says "Superseded", the later note wins.

## Language and layout
Python 3.12 (the spec's pseudocode is Python). Package `lucifer/`, tests in `tests/`, config via pydantic models. The language choice must be locked in the spec during Step 0, before code is written. Lint, type-check and test commands are also decided in Step 0; do not assume specific tools until then.

## Invariants — do not break without asking
- Errors: exactly three categories (`SELF_CORRECTABLE`, `INFRA`, `UNSAFE`); every error type maps to exactly one; no separate "retryable" flag (§5.1). `INFRA` never counts toward stuck-detection or tool/verification budgets. `UNSAFE` = hard abort, no override, no resume.
- Every tool returns the typed result envelope (§5.2); schema validation happens before dispatch (§5.6).
- Tool set is 11 tools incl. `dispatch_agent` (§6). `search_code` is offered (single-stage, `text-embedding-3-small`); no reranker in v0 — it is a dormant, config-swappable seam.
- The sandbox (bubblewrap-style namespaces + seccomp, §6.2) is the real security boundary, not the command allowlist. Shared `is_within_repo_root` predicate for all path checks. Mutating git subcommands are blocked in `run_command`.
- Workspace (in-memory staging) is the source of truth until `commit()`; sandbox is a synced copy with host-side change detection (§7).
- Verification suite = explicit per-repo config only. No auto-detection fallback. No suite → skip baseline + done-gate, and surface `verification_status` at diff review.
- Model IDs are `<provider>/<model>` strings, one combined `ModelSpec.id`. Per-model context/max-output numbers come from the registry table (§2), never hard-coded elsewhere.
- `text-embedding-3-small` is reached via `direct_endpoint`, outside the Gateway.
- Escalation is the safety net: don't add retry layers the spec doesn't define.
- Open values (C53 `direct_endpoint` config, C58 `SKILL_MATCH_THRESHOLD`, C59 `MAX_ACTIVE_SKILLS`): implement as config with a clearly marked placeholder default; do not invent final numbers.

## Working rules
1. Plan first for each subsystem: restate the section's contract, list ambiguities, ask before guessing.
2. Tests first, derived from the spec's pseudocode and error taxonomy. Use a fake Gateway; never call real models in unit tests.
3. When code and spec disagree, stop and flag it; do not silently pick one. Spec edits bump the version and get a changelog line (made in the source repo, not this mirror).
4. After each subsystem, run a separate review pass against that spec section and the checklist entries touching it (use the `lucifer-reviewer` agent or the `/lucifer-review-pass` skill).

## How Spec Kit fits
Each `BUILD_ORDER.md` step is one Spec Kit feature. Start with `/lucifer-start-step <N>`; it prepares the section list, checklist entries and open questions, then you run the `/speckit-*` skills in order: `specify` → (`clarify`) → `plan` → `tasks` → (`analyze`) → `implement`.
- `/speckit-specify` takes the *what and why* of the step (BUILD_ORDER "Deliver" and "Accept"). The spec already fixes the design, so reference sections by number rather than restating them.
- `/speckit-plan` must pass the Constitution Check, and the plan must cite the spec sections it implements.
- `/speckit-tasks` must put tests before implementation for each unit.
- Do not let Spec Kit generate design that the Lucifer spec already decides. If it wants to, that is an ambiguity: ask.

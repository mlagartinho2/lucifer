# Lucifer — build order

Each step lists the spec sections to load, deliverable, and an acceptance test. Do one step per session; commit when its acceptance test passes. Later steps depend on earlier ones.

## Step 0 — Repo skeleton
Load: `00-component-map`, `01-purpose-system-context`, CLAUDE.md. Lock Python, add `pyproject.toml`, `lucifer/`, `tests/`, lint/type-check/test commands, `git init`.
Accept: `pytest` runs (empty), CI-style command runs clean.

## Step 1 — Model registry + Gateway client
Load: `02-model-registry-shape`; checklist C12, C13, C21, C53.
Deliver: `ModelSpec`, registry table with the real per-model numbers, OpenAI-compatible client, `direct_endpoint` path, a fake Gateway for tests.
Accept: registry loads all models; fake gateway round-trip; direct-endpoint config read from env vars; failed calls surface as `GATEWAY_ERROR`.

## Step 2 — Typed errors, result envelope, schema validation
Load: `05-error-handling-safety-model` (§5.1–5.3, 5.6).
Deliver: error taxonomy, `ToolResult` envelope, pre-dispatch validation.
Accept: every error type maps to exactly one category; invalid args yield `SCHEMA_VALIDATION_ERROR` without dispatch.

## Step 3 — Workspace, staging, commit
Load: `07-workspace-staging-model`; checklist C35, C38, C42.
Deliver: in-memory workspace, file status/staleness, sensitive-path predicate, diff + partial approval model, `commit()` via `update-ref`, session snapshot marker.
Accept: against a temp git repo: stage, stale-view rejection, commit on branch and on detached HEAD, drift check.

## Step 4 — Sandbox + `run_command`
Load: `06-tool-set` §6.2, `07` §7.3–7.4; checklist C1, C20, C37.
Deliver: bubblewrap invocation, synced copy with host-side change detection, per-repo allowlist, process-group timeout, resource limits.
Accept (Linux only): writes outside mount fail; blocked git subcommands rejected; timeout kills process group; changes sync back to workspace.

## Step 5 — Remaining tools
Load: `06-tool-set` §6.1, 6.3–6.5.
Deliver: `read_file`, `list_directory`, `grep_search`, `edit_file` (find/replace blocks), `create_file`, `get_diagnostics` (shell-out), `ask_user`, `done`.
Accept: edit ambiguity/not-found errors, path-outside-repo, diagnostics via repo's own linter.

## Step 6 — Agent loop + budgets + verification gate
Load: `03-agent-execution-loop`; checklist C8, C15, C47, C51.
Deliver: reactive loop, eight budgets, stuck-repeat detection (exact-equality thresholds), `done` gate with baseline-diffed verification, suspend/resume (§5.5).
Accept: scripted fake-gateway trajectories hit each budget, each abort path, and the no-suite path with `verification_status`.

## Step 7 — Routing and escalation
Load: `04-model-routing`; checklist C16, C21, C36.
Deliver: triage model, `ESCALATION_PATH`, overrides, per-model effort token tables.
Accept: escalation fires at the thresholds; `max_tokens_for` returns distinct tiers per model.

## Step 8 — Context management and compaction
Load: `08-context-management-compaction`; checklist C17.
Accept: compaction triggers at 0.65 of the model's real window; workspace stays authoritative after compaction.

## Step 9 — Retrieval and indexing
Load: `09-retrieval-indexing`; checklist C26, C40, C52, C54.
Deliver: tree-sitter chunker, `text-embedding-3-small` index, first-time index build, `search_code`, capability-withdrawal after repeated gateway failures.
Accept: index a fixture repo, semantic query returns the expected chunk, withdrawal flag after threshold.

## Step 10 — CLI presenter
Load: `10-cli-presenter-layer`.
Deliver: interactive `lucifer`, non-interactive `lucifer run|exec`, diff review and partial approval, `--agent`.
Accept: end-to-end task on a fixture repo, interactive and non-interactive.

## Step 11 — Custom agents, skills, `dispatch_agent`
Load: `06-tool-set` §6.6; checklist C55–C59.
Accept: persona select via `--agent`, skill discovery and threshold match, nested dispatch.

## Step 12 — Spec hygiene pass
Re-run the self-audit Section B cross-reference check at current spec size; reconcile any code/spec drift found along the way.

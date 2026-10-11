# Lucifer — build order

Each step lists the spec sections to load, deliverable, and an acceptance test. Do one step per session; commit when its acceptance test passes. Later steps depend on earlier ones.

Checklist ids under `Load:` are the entries to read (grep each id; never the whole checklist). Open items (C53, C58, C59) are implemented as configuration with a clearly marked placeholder default, never an invented final value.

## Step 0 — Repo skeleton
Load: `00-component-map`, `01-purpose-system-context`, CLAUDE.md. Lock Python, add `pyproject.toml`, `lucifer/`, `tests/`, lint/type-check/test commands, `git init`.
Accept: `pytest` runs (empty), CI-style command runs clean.

## Step 1 — Model registry + Gateway client
Load: `02-model-registry-shape`; `05` §5.1 (the `GATEWAY_ERROR` entry only); checklist C6, C12, C13, C21, C53 (open: placeholder config).
Deliver: `ModelSpec`, registry table with the real per-model numbers, OpenAI-compatible client, `direct_endpoint` path, a fake Gateway for tests.
Accept: the live registry config loads and validates every model listed in it (chat models plus exactly one embedding entry), with per-model numbers taken from the §2 catalog table; a config with two embedding entries is rejected; fake gateway round-trip; direct-endpoint config read from env vars; failed Gateway or `direct_endpoint` calls surface as `GATEWAY_ERROR` (§5.1; Step 1 needs only this one type, Step 2 builds the full taxonomy around it).

## Step 2 — Typed errors, result envelope, schema validation
Load: `05-error-handling-safety-model` (§5.1–5.3, 5.6); checklist C19.
Deliver: error taxonomy (including the `GATEWAY_ERROR` type Step 1 introduced), `ToolResult` envelope, pre-dispatch validation.
Accept: every error type maps to exactly one category; invalid args yield `SCHEMA_VALIDATION_ERROR` without dispatch.

## Step 3 — Workspace, staging, commit
Load: `07-workspace-staging-model`; `05` §5.4 (risk-flag triggers); checklist C3, C4, C7, C11, C23, C28, C34, C35, C38, C39, C42, C45.
Deliver: in-memory workspace, file status/staleness, sensitive-path predicate, diff + partial approval model, risk-flag evaluation over the staged diff (the suspend it triggers is wired in Step 6), `commit()` via `update-ref`, session snapshot marker.
Accept: against a temp git repo: stage, stale-view rejection, commit on branch and on detached HEAD, drift check.

## Step 4 — Sandbox + `run_command`
Load: `06-tool-set` §6.2, `07` §7.3–7.4; checklist C1, C5, C20, C37.
Deliver: bubblewrap invocation, synced copy with host-side change detection, per-repo allowlist, process-group timeout, resource limits.
Accept (Linux only): writes outside mount fail; blocked git subcommands rejected; timeout kills process group; changes sync back to workspace.

## Step 5 — Remaining tools
Load: `06-tool-set` intro (tool table and argument schemas), §6.1, §6.3–6.5; `07` §7.8 (new-file lifecycle, for `create_file`); checklist C9, C24, C25, C31.
Deliver: `read_file`, `list_directory`, `grep_search`, `edit_file` (find/replace blocks), `create_file`, `get_diagnostics` (shell-out), `ask_user`, `done`.
Accept: edit ambiguity/not-found errors, path-outside-repo, diagnostics via repo's own linter.

## Step 6 — Agent loop + budgets + verification gate
Load: `03-agent-execution-loop`; `05` §5.3–5.5; checklist C8, C10, C15, C28, C30, C41, C47, C51.
Deliver: reactive loop, eight budgets, stuck-repeat detection (exact-equality thresholds), `done` gate with baseline-diffed verification, the §5.4 suspend and review-pause states, suspend/resume (§5.5).
Accept: scripted fake-gateway trajectories hit each budget, each abort path, and the no-suite path with `verification_status`.

## Step 7 — Routing and escalation
Load: `04-model-routing`; checklist C2, C16, C21, C36, C44.
Deliver: triage model, `ESCALATION_PATH`, overrides, per-model effort token tables, load-time validation (§4.1, §4.3).
Accept: escalation fires at the thresholds; `max_tokens_for` returns distinct tiers per model; a registry with zero or more than one `is_default_triage_model=True` chat-pool model, or an `ESCALATION_PATH` naming an unknown or non-tool-calling model, is rejected at load.

## Step 8 — Context management and compaction
Load: `08-context-management-compaction`; checklist C17, C22, C33.
Deliver: transcript compaction with the protected tier (system prompt/tool schema/task, recent turns, pending diffs, active error messages, pinned escalation-event records); outside it, drop → reference-evict → model-summarize applied in that order; tier-2 pointers (C33).
Accept: compaction triggers at `DEFAULT_COMPACT_THRESHOLD_PCT = 0.65` of the active model's real `context_window` (no per-model override is set for the four `ESCALATION_PATH` models); an escalation event is pinned and survives compaction; workspace stays authoritative after compaction.

## Step 9 — Retrieval and indexing
Load: `09-retrieval-indexing`; checklist C18, C26, C32, C40, C48, C49, C50, C52, C54.
Deliver: tree-sitter chunker, `text-embedding-3-small` index, first-time index build, `search_code` (via Step 1's `direct_endpoint` client), capability-withdrawal after repeated gateway failures. Reranking is a dormant, config-swappable seam and is not built in v0 (C14, C43, C46 are moot: superseded in v0.65, dormant). In v0, `adaptive_top_k` sizes only the recall pass; in-session-edited chunks are all included after the recall hits, and §5.2's output cap is the only bound on the combined result (§9, C32, v0.71).
Accept: index a fixture repo, semantic query returns the expected chunk, `retrieval_capability_withdrawn` set after the threshold.

## Step 10 — CLI presenter
Load: `10-cli-presenter-layer`; checklist C27, C29, C30.
Deliver: interactive `lucifer`; non-interactive subcommand (§10 leaves the name open between `lucifer run` and `lucifer exec`: choose one and record it in the spec); diff review and partial approval; extended-budget grant on resume (C29); wind-down summary display (C30); `--agent <name>` accepted and passed through (resolving it to an agent definition is Step 11).
Accept: end-to-end task on a fixture repo, interactive and non-interactive.

## Step 11 — Custom agents, skills, `dispatch_agent`
Load: `06-tool-set` §6.6; `10` (the `--agent` widening); `03` §3.2 (shared budgets); checklist C55–C59 (C58, C59 open: placeholder config).
Deliver: custom agent definitions (`.md` + YAML frontmatter, discovered from `.github/agents/`, `.claude/agents/` and personal equivalents); skill definitions (`SKILL.md`, discovered from `.github/skills/`, `.claude/skills/`, `.agents/skills/` and personal equivalents) activated by embedding-similarity match through §9's pipeline, with `SKILL_MATCH_THRESHOLD` and `MAX_ACTIVE_SKILLS` as placeholder config; the `dispatch_agent` tool (isolated sub-context, shared parent budgets, counters reset on return, sequential only); persona-select via `--agent`.
Accept: persona select via `--agent`, skill discovery and threshold match, nested dispatch, recursion stops at `AGENT_DISPATCH_DEPTH = 3`.

## Step 12 — Spec hygiene pass
Re-run the self-audit Section B cross-reference check at current spec size; reconcile any code/spec drift found along the way.

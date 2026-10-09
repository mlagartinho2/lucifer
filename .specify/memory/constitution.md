# Lucifer Constitution

Lucifer is an in-house coding agent (functional equivalent of GitHub Copilot) running on org-hosted models behind one OpenAI-compatible Gateway. It is CLI-first, uses Linux-only sandbox hosts with one dedicated VM per session, and always targets git repositories.

This constitution is derived from the project's `CLAUDE.md` invariants and the Lucifer spec (`docs/spec/`, currently v0.69). It does not add design decisions of its own. Where it and the spec disagree, the spec wins and the disagreement must be raised (Principle I).

## Core Principles

### I. The Spec Is Authoritative (NON-NEGOTIABLE)
The split spec in `docs/spec/NN-*.md` and the resolution status in `LUCIFER_IMPLEMENTATION_CHECKLIST_v1.md` (C1–C59) define behaviour. Treat "Resolved (vX.Y)" notes as authoritative; if a later note says "Superseded", the later note wins. When code and spec disagree, STOP and flag it; never silently pick one. Spec edits bump the spec version and add a changelog line, and they are made in the source repository, not in this mirror.

### II. Exactly Three Error Categories (NON-NEGOTIABLE)
Errors are `SELF_CORRECTABLE`, `INFRA` or `UNSAFE`. Every error type maps to exactly one category. There is no separate "retryable" flag (§5.1). `INFRA` never counts toward stuck-detection or tool/verification budgets. `UNSAFE` is a hard abort with no override and no resume.

### III. Typed Envelope, Validated Before Dispatch
Every tool returns the typed result envelope (§5.2). Schema validation happens before dispatch (§5.6); invalid arguments yield `SCHEMA_VALIDATION_ERROR` without dispatching. The tool set is 11 tools including `dispatch_agent` (§6). `search_code` is offered as single-stage retrieval with `text-embedding-3-small`; there is no reranker in v0 (a dormant, config-swappable seam only).

### IV. The Sandbox Is the Security Boundary
The sandbox (bubblewrap-style namespaces + seccomp, §6.2) is the real boundary, not the command allowlist. All path checks use one shared `is_within_repo_root` predicate. Mutating git subcommands are blocked in `run_command`. Sandbox hosts are Linux only.

### V. Workspace Is the Source of Truth Until `commit()`
The in-memory Workspace (staging) is authoritative until `commit()`. The sandbox is a synced copy with host-side change detection (§7). Compaction never changes this.

### VI. Test-First, Against a Fake Gateway
Tests are written first, derived from the spec's pseudocode and error taxonomy. Unit tests use a fake Gateway and never call real models.

### VII. No Invented Behaviour or Values
Escalation is the safety net: do not add retry layers the spec does not define. Open values (C53 `direct_endpoint` config, C58 `SKILL_MATCH_THRESHOLD`, C59 `MAX_ACTIVE_SKILLS`) are implemented as configuration with a clearly marked placeholder default; never invent final numbers. Per-model context and max-output numbers come only from the registry table (§2) and are never hard-coded elsewhere.

## Fixed Technical Decisions

- **Language/layout**: Python 3.12 (the spec's pseudocode is Python); package `lucifer/`, tests in `tests/`, configuration via pydantic models. The language choice has not yet been formally locked in the spec; locking it is part of build Step 0, before any code is written.
- **Model IDs**: `<provider>/<model>` strings held in one combined `ModelSpec.id`.
- **Embeddings**: `text-embedding-3-small` is reached via `direct_endpoint`, outside the Gateway.
- **Verification**: the suite is explicit per-repo config only. No auto-detection fallback. With no suite, skip the baseline and the done-gate and surface `verification_status` at diff review.

## Development Workflow

- Follow `BUILD_ORDER.md`: one step per session and per Spec Kit feature; commit when the step's acceptance test passes. Later steps depend on earlier ones.
- Plan first for each subsystem: restate the section's contract, list ambiguities, and ask before guessing.
- After each subsystem, run a separate review pass against that spec section and the checklist entries touching it.
- Context discipline: load only the section being built plus `docs/spec/00-component-map.md`. Never load `docs/spec/_preamble-and-changelog.md` or `docs/spec/13-*.md` whole; search the checklist with grep instead of reading it whole. `archive/` is stale and is never read or edited.

## Governance

This constitution supersedes ad-hoc practice for this repository. Changing any invariant above requires asking the project owner first and, if the spec is affected, a spec version bump with a changelog line. Every plan's Constitution Check and every review pass must verify compliance with Principles I–VII.

**Version**: 1.0.0 | **Ratified**: 2026-10-09 | **Last Amended**: 2026-10-09

## 0. Component Map

Purely descriptive, derived from the decisions below — not a new design choice:

- **CLI Presenter** — the only editor-integration surface in v0. Renders diffs, prompts `ask_user`/pause interactions, streams model output.
- **Orchestrator / Agent Loop** — drives the reactive loop, owns the budgets, stuck-repeat detection, and the suspend/resume state machine.
- **Model Router** — triage (start-of-trajectory) and escalation (mid-trajectory), sitting in front of the Gateway.
- **Gateway** — single OpenAI-compatible API surface in front of all org-hosted models, with one confirmed exception: `text-embedding-3-small` is reached directly via a separate Azure OpenAI subscription (§1/§2's `direct_endpoint`, v0.65).
- **Tool Executors** — 11 tools as of v0.69 (§6.6 widens the previously-locked 10-tool count by one, `dispatch_agent`); each returns the typed result envelope.
- **Workspace** — in-memory staging area for edits; source of truth until `commit()`.
- **Sandbox** — synced on-disk copy of the repo that `run_command` actually executes against.
- **Verification** — baseline-diffed check run at the `done` gate.
- **Context Manager / Compaction** — keeps the transcript inside its token budget while Workspace stays authoritative.
- **Retrieval / Index** — embedding-based recall (single-stage as of v0.65, via `text-embedding-3-small` — see §9) over an AST/symbol-chunked, repo-scoped index; cross-encoder reranking is a documented, currently-dormant seam, not part of v0's shipped pipeline.
- **Custom Agents & Skills** (v0.69) — operator/repo-authored `.md` files defining specialist personas (agents) and reusable, auto-discovered capability bundles (skills), layered on top of the single existing agent loop rather than a second orchestrator — see §6.6.

---

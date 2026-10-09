## 11. Explicit Non-Goals (v0)

Restated from the locked decisions, grouped by area for traceability:

- **Loop design:** upfront multi-step planning before execution (§3.1).
- **Edit format:** unified diffs or full-file rewrites (§6.1).
- **Tool-calling format:** a custom text-based tool-calling format — rejected once the Gateway was confirmed to support native tool calls (§1).
- **`run_command` policy:** denylist-only command policy (§6.2); blocking all git commands outright, as opposed to just mutating subcommands (§6.2).
- **Staging safety:** force-adding all files past `.gitignore` (§7.4) — reopens the exact risk sensitive-path checks exist to prevent.
- **Safety routing:** treating a risk-based review interrupt as equivalent to `ErrorCategory.UNSAFE` (§5.4).
- **Commit-time conflicts:** auto-merge on an external-change conflict at commit time (§7.6) — detected and refused, not resolved automatically, for v0.
- **Partial approval:** dependency analysis for true file-coupling (§7.5); committing an approved subset while the rest of the round is still being retried (§7.5).
- **Checkpoint/resume:** persisting the sandbox's pending-sync queue verbatim across a checkpoint (§7.7) — rebuilt from current state instead.
- **Change detection:** git state as the mechanism for detecting sandbox changes (§7.3) — replaced with the host-side content snapshot after repeated failure modes.
- **Concurrency:** locking or arbitration between multiple concurrent Workspace sessions on the same repo (§7.9).
- **Error taxonomy:** adding new error types for resource-limit violations — routed through the existing `INFRA` category instead (§5.1).
- **Tool set:** `delete_file`/`rename_file` — deliberately deferred, not designed for v0 (§6); when eventually added, would route through the same diff-approval flow as other mutating tools. Noted here explicitly (consistency check, A2) so the omission reads as a scope decision, not an oversight.

---

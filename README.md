# Lucifer — Copilot + Spec Kit workspace

This folder is a ready-to-open VS Code workspace for building Lucifer with GitHub Copilot Chat and [GitHub Spec Kit](https://github.com/github/spec-kit). It holds the Copilot customization files, a Spec Kit scaffold (generated with `specify init --integration copilot`, Spec Kit 1.1.2) and a read-only mirror of the spec.

## Open it

1. Install VS Code with the **GitHub Copilot** and **GitHub Copilot Chat** extensions and sign in (VS Code will offer the recommended extensions from `.vscode/extensions.json`).
2. `File → Open Folder…` and choose **this `copilot` folder** (not the parent). Spec Kit and Copilot look for `.specify/` and `.github/` at the workspace root.
3. Initialise git here once: `git init && git add -A && git commit -m "Initial Copilot + Spec Kit scaffold"`. Lucifer's target repos are git repos, and Step 0 of the build order expects it.
4. In Copilot Chat, type `/` — you should see the `speckit-*` and `lucifer-*` skills. If you do not, reload the window.

## What is in here

| Path | Purpose |
|---|---|
| `.github/copilot-instructions.md` | Always-on project rules: invariants, context discipline, working rules |
| `.github/instructions/*.instructions.md` | File-scoped rules for `lucifer/**/*.py`, `tests/**/*.py` and the spec mirror |
| `.github/skills/speckit-*` | The Spec Kit commands (`/speckit-specify`, `-plan`, `-tasks`, `-implement`, …) |
| `.github/skills/lucifer-start-step` | `/lucifer-start-step <N>`: plan-first gate for a BUILD_ORDER step |
| `.github/skills/lucifer-review-pass` | `/lucifer-review-pass <N>`: post-subsystem review checklist |
| `.github/agents/lucifer-reviewer.agent.md` | Read-only reviewer agent for an independent review |
| `.specify/` | Spec Kit scripts and templates, and `memory/constitution.md` (pre-filled for Lucifer) |
| `docs/spec/`, `BUILD_ORDER.md`, `LUCIFER_IMPLEMENTATION_CHECKLIST_v1.md`, `LUCIFER_SPEC_selfaudit_v0.2.md` | Read-only mirror of the spec material |
| `scripts/sync-spec.sh` | Refreshes the mirror from the parent Lucifer folder |
| `.vscode/` | Copilot, search and Python settings; extension recommendations |

`lucifer/` and `tests/` do not exist yet; Step 0 creates them.

## Workflow: one BUILD_ORDER step = one Spec Kit feature

Do one step per chat session and commit when its acceptance test passes.

1. **Step 0 only**: run `/speckit-constitution` if you want to amend the pre-filled constitution (it already encodes the CLAUDE.md invariants). Step 0 must also lock Python in the spec and decide the lint, type-check and test commands. This folder holds a read-only mirror, so make the spec edit in the source Lucifer folder (version bump + changelog line), then run `scripts/sync-spec.sh`.
2. `/lucifer-start-step <N>` — loads only that step's spec sections and checklist entries, lists ambiguities, and drafts the inputs for the next two commands. Answer its questions.
3. `/speckit-specify` with the drafted *what/why* text, then optionally `/speckit-clarify`.
4. `/speckit-plan` with the drafted technical constraints. The plan's Constitution Check must pass.
5. `/speckit-tasks`, then optionally `/speckit-analyze`.
6. `/speckit-implement` (tests first, fake Gateway only).
7. Review: in a **new chat**, run `/lucifer-review-pass <N>`, or pick the `lucifer-reviewer` agent. Fix findings, then commit.
8. Optionally `/speckit-converge` to check what remains.

If code and spec ever disagree, stop and fix the spec in the source repo (version bump + changelog line), then run `scripts/sync-spec.sh`.

## Keeping the spec in sync

The spec material here is a snapshot of the parent Lucifer folder, taken on 2026-10-12 (spec v0.72). After any change in the source, run:

```bash
scripts/sync-spec.sh          # source defaults to the parent folder
```

`archive/`, `CLAUDE.md` and the 624 KB `LUCIFER_SPEC_v0_draft.md` are deliberately not mirrored.

## Notes

- Never load `docs/spec/_preamble-and-changelog.md` or `docs/spec/13-*.md` whole into a chat (~150 KB each). The instructions and settings already steer Copilot away from this; keep it in mind when attaching files by hand.
- The sandbox work (Step 4) targets Linux hosts. On macOS, run those tests inside a Linux container or VM; they are marked Linux-only.
- Spec Kit files under `.github/skills/speckit-*` and `.specify/` are generated. Update them with the Specify CLI rather than editing them by hand, so they can be upgraded cleanly. Put project-specific behaviour in the constitution, the instructions and the `lucifer-*` skills.
- `.github/` is committed. If you ever put credentials in a Copilot-related folder, add it to `.gitignore` first.

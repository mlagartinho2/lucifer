---
name: lucifer-start-step
description: Prepare a Lucifer BUILD_ORDER step for Spec Kit. Restates the contract, lists the exact spec sections and checklist entries to load, surfaces ambiguities, and drafts the /speckit-specify input. Use at the start of every build step.
argument-hint: "<step number 0-12>"
disable-model-invocation: true
---

# Start a Lucifer build step

Input: a step number from `BUILD_ORDER.md` (`$ARGUMENTS`). If none is given, ask which step.

This is the "plan first, ask before guessing" gate. Do **not** write code or create files in `lucifer/` or `tests/` in this skill.

## Procedure

1. Read `BUILD_ORDER.md` and extract the entry for the requested step (its "Load", "Deliver" and "Accept" lines). Check that earlier steps it depends on are done: look for the corresponding code and tests, and say plainly what is missing.
2. Load **only** what the step names, honouring the context rules in `.github/copilot-instructions.md`:
   - `docs/spec/00-component-map.md` plus the listed section files. For a large section file, read only the subsection numbers the step names (for example "§6.2").
   - For each checklist id in the step (for example C12, C13), run `grep -n 'C12' LUCIFER_IMPLEMENTATION_CHECKLIST_v1.md` and read only those entries. Prefer the latest "Resolved" or "Superseded" note.
   - Never open `docs/spec/_preamble-and-changelog.md` or `docs/spec/13-*.md` whole.
3. Write a short brief with these headings:
   - **Contract**: what the spec section requires, in your own words, with section numbers.
   - **Real values**: concrete numbers or names the spec/checklist fixes for this step, each with its source. Open values (C53, C58, C59) are listed as placeholders and not filled in.
   - **Ambiguities and spec/code conflicts**: everything unclear or inconsistent. Do not resolve these yourself.
   - **Invariants touched**: which items of the constitution (`.specify/memory/constitution.md`) apply.
4. If there are ambiguities, ask the user to resolve them before going on. Ask at most one batch of questions.
5. Once resolved, draft the text for `/speckit-specify`. It describes **what and why** (the step's "Deliver" and "Accept" as user-visible behaviour and testable outcomes), cites spec sections by number rather than restating design, and contains no framework or file-layout choices. Give a second block for `/speckit-plan` with the technical constraints that apply (Python 3.12, package `lucifer/`, tests in `tests/`, pydantic config, fake Gateway for tests, the spec sections to implement).
6. End by telling the user to run, in order: `/speckit-specify <block 1>`, optionally `/speckit-clarify`, `/speckit-plan <block 2>`, `/speckit-tasks`, optionally `/speckit-analyze`, then `/speckit-implement`. Remind them that Step 0 must also lock the Python choice in the spec and decide the lint/type-check/test commands.

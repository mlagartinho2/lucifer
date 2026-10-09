---
name: lucifer-review-pass
description: Run the separate post-subsystem review pass for a Lucifer build step. Checks the code and tests against the spec section, the checklist entries, the constitution and the step's acceptance test.
argument-hint: "<step number 0-12>"
disable-model-invocation: true
---

# Review pass for a Lucifer build step

Input: a step number from `BUILD_ORDER.md` (`$ARGUMENTS`). If none is given, ask which step.

This is the review pass the working rules require after each subsystem. It is read-only: report findings, do not fix them. For the most independent result, run it in a fresh chat or with the `lucifer-reviewer` agent, not in the chat that wrote the code.

## Procedure

1. Read the step's entry in `BUILD_ORDER.md`. Load only the spec sections and checklist entries it names (plus `docs/spec/00-component-map.md`), using grep for the checklist and never loading `docs/spec/_preamble-and-changelog.md` or `docs/spec/13-*.md` whole. Read `.specify/memory/constitution.md`.
2. Read the code and tests that implement the step. Find them from the feature's Spec Kit folder under `specs/` and from `lucifer/` and `tests/`.
3. Check, and record pass/fail with a file and line for each:
   - **Spec conformance**: every rule in the cited sections is implemented as written; nothing extra is invented (no added retry layers, no new error categories, no hard-coded registry numbers).
   - **Checklist conformance**: each C-entry touching the step is honoured. Where a note says "Superseded", the later note is the one followed.
   - **Constitution**: Principles I–VII, one by one.
   - **Tests**: written from the spec's pseudocode and error taxonomy; use the fake Gateway only; the step's acceptance test exists and passes.
   - **Open values**: C53, C58, C59 are config with a marked placeholder default, not final numbers.
   - **Code/spec disagreement**: list every case, quoted from both sides. Do not pick a side.
4. Output a list of findings ordered by severity, each with the file and line, the spec section or checklist id it violates, and a one-line suggested fix. Then give a verdict: "ready to commit" only if the acceptance test passes and there are no spec or constitution violations.

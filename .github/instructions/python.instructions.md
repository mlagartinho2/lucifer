---
name: Lucifer Python code
description: Rules for writing or changing Python source in the lucifer package
applyTo: "lucifer/**/*.py"
---

# Python source rules (`lucifer/`)

- Target Python 3.12. Use full type hints; configuration models are pydantic models.
- Model IDs are `<provider>/<model>` strings in a single `ModelSpec.id`. Never split them, and never hard-code per-model context or max-output numbers; read them from the registry table (§2).
- Every error type maps to exactly one of `SELF_CORRECTABLE`, `INFRA`, `UNSAFE`. Do not add a `retryable` flag or any retry layer the spec does not define.
- Every tool returns the typed result envelope (§5.2). Validate arguments against the schema before dispatch (§5.6).
- Every path check goes through the shared `is_within_repo_root` predicate. Do not write a second, local path check.
- Edits go to the in-memory Workspace; nothing reaches disk before `commit()`.
- Open values (C53, C58, C59) are config fields with a clearly marked placeholder default (for example a `# PLACEHOLDER: open item C58` comment). Never invent a final number.
- Reach `text-embedding-3-small` only via `direct_endpoint`, never through the Gateway client.
- Cite the spec section in a docstring or comment where you implement a rule from it (for example `# §5.2`). Keep these short.
- If the code you are about to write would disagree with the spec or checklist, stop and say so instead of choosing.

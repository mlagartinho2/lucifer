---
name: Lucifer tests
description: Rules for writing or changing tests under tests/
applyTo: "tests/**/*.py"
---

# Test rules (`tests/`)

- Tests come first. Derive them from the spec section's pseudocode and from the error taxonomy (§5.1), not from an implementation you already wrote.
- Use the fake Gateway. Unit tests must never call real models or the network.
- Name tests after the behaviour and cite the spec section or checklist id in the docstring (for example "§5.6: invalid args yield SCHEMA_VALIDATION_ERROR without dispatch").
- For error handling, assert both the error type and its single category. Assert that `INFRA` errors do not consume stuck-detection or tool/verification budgets, and that `UNSAFE` cannot be overridden or resumed.
- The acceptance test of the current `BUILD_ORDER.md` step must exist as an automated test before the step is considered done.
- Sandbox tests run on Linux only and must be marked so they are skipped elsewhere.
- Use a temporary git repository for workspace/commit tests rather than the project's own repository.

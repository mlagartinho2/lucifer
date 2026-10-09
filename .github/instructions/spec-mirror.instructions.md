---
name: Lucifer spec mirror (read-only)
description: Rules for reading the mirrored spec, checklist and build order
applyTo: "docs/spec/**,LUCIFER_IMPLEMENTATION_CHECKLIST_v1.md,BUILD_ORDER.md,LUCIFER_SPEC_selfaudit_v0.2.md"
---

# Spec mirror rules

These files are a read-only copy of the source repository, refreshed by `scripts/sync-spec.sh`. Do not edit them here; edits would be lost on the next sync and would hide drift.

- If the spec is wrong, ambiguous or contradicts the code, report it with the section number and stop. A spec change means a version bump and a changelog line in the source repository.
- Never load `docs/spec/_preamble-and-changelog.md` or `docs/spec/13-*.md` whole. Use grep to find the entry you need and read only that part.
- Read the checklist with grep (`grep -n 'C21' LUCIFER_IMPLEMENTATION_CHECKLIST_v1.md`) and read only the entries that match.
- "Resolved (vX.Y)" notes are authoritative; a later "Superseded" note wins over an earlier one.

#!/usr/bin/env bash
# Refresh the read-only spec mirror in this folder from the source Lucifer repo.
#
# Usage:  scripts/sync-spec.sh [SOURCE_DIR]
# SOURCE_DIR defaults to the parent directory of this folder (the Lucifer root).
#
# Copies only what the build needs. It never copies archive/, the 624 KB
# LUCIFER_SPEC_v0_draft.md, CLAUDE.md or the cross-check file.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${1:-$(cd "$HERE/.." && pwd)}"

if [ ! -d "$SRC/docs/spec" ]; then
  echo "error: $SRC/docs/spec not found. Pass the Lucifer root as the first argument." >&2
  exit 1
fi
if [ "$SRC" = "$HERE" ]; then
  echo "error: source and destination are the same folder." >&2
  exit 1
fi

echo "Syncing spec mirror from: $SRC"

# docs/spec/*.md (replace the directory so removed sections disappear too)
rm -rf "$HERE/docs/spec"
mkdir -p "$HERE/docs/spec"
cp "$SRC"/docs/spec/*.md "$HERE/docs/spec/"

for f in BUILD_ORDER.md LUCIFER_IMPLEMENTATION_CHECKLIST_v1.md LUCIFER_SPEC_selfaudit_v0.2.md; do
  if [ -f "$SRC/$f" ]; then
    cp "$SRC/$f" "$HERE/$f"
  else
    echo "warning: $f not found in source, skipped" >&2
  fi
done

echo "Done. Spec files: $(ls "$HERE/docs/spec" | wc -l | tr -d ' ')"
echo "Mirror is read-only by convention: edit the spec in the source repo, then re-run this script."

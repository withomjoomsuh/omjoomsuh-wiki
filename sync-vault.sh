#!/usr/bin/env bash
set -euo pipefail

VAULT="$HOME/Documents/OMJOOMSUH wiki"
CONTENT="$HOME/quartz/content"

# Clear content dir (keep .gitkeep if present)
find "$CONTENT" -mindepth 1 -delete 2>/dev/null || true

# Copy included folders
for folder in "00 — Essays" "10 — Concepts" "20 — People"; do
  if [ -d "$VAULT/$folder" ]; then
    cp -r "$VAULT/$folder" "$CONTENT/$folder"
  fi
done

# Copy root files
if [ -f "$VAULT/The Door.md" ]; then
  cp "$VAULT/The Door.md" "$CONTENT/The Door.md"
fi
if [ -f "$VAULT/index.md" ]; then
  cp "$VAULT/index.md" "$CONTENT/index.md"
fi

# Remove excluded items that may have been pulled in transitively
for excl in "Concept Template.md"; do
  find "$CONTENT" -name "$excl" -delete
done

echo "Sync complete: $(find "$CONTENT" -name '*.md' | wc -l | tr -d ' ') markdown files."

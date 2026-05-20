#!/usr/bin/env bash
set -euo pipefail

VAULT="$HOME/Documents/AI/MD Files/OMJOOMSUH wiki"
CONTENT="$HOME/quartz/content"

# SAFETY GUARD: abort if the vault directory doesn't exist
if [ ! -d "$VAULT" ]; then
  echo "ERROR: Vault directory not found at: $VAULT"
  echo "ABORTING sync. No files have been changed."
  exit 1
fi

# SAFETY GUARD: abort if Essays folder is missing (vault looks empty/wrong)
if [ ! -d "$VAULT/00 — Essays" ]; then
  echo "ERROR: Essays folder not found inside vault: $VAULT/00 — Essays"
  echo "Vault may have moved or been renamed. ABORTING sync."
  exit 1
fi

# SAFETY GUARD: abort if vault is suspiciously empty (fewer than 10 .md files)
VAULT_MD_COUNT=$(find "$VAULT/00 — Essays" "$VAULT/10 — Concepts" "$VAULT/20 — People" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$VAULT_MD_COUNT" -lt 10 ]; then
  echo "ERROR: Vault has only $VAULT_MD_COUNT markdown files — looks empty or broken."
  echo "ABORTING sync to prevent wiping the live wiki."
  exit 1
fi

echo "Vault verified: $VAULT_MD_COUNT markdown files found. Proceeding with sync."

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

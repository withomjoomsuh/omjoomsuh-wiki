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

# Copy image folders into 10 — Concepts so embeds resolve correctly
if [ -d "$VAULT/Surya Namaskara (images)" ]; then
  cp -r "$VAULT/Surya Namaskara (images)" "$CONTENT/10 — Concepts/Surya Namaskara (images)"
  echo "  Copied: Surya Namaskara (images)"
fi

# Copy root files — these are critical and must exist in the vault
if [ -f "$VAULT/The Door.md" ]; then
  cp "$VAULT/The Door.md" "$CONTENT/The Door.md"
else
  echo "ERROR: The Door.md missing from vault root at $VAULT/The Door.md"
  echo "Refusing to complete sync — The Door is the wiki's primary entry point."
  echo "Restore The Door.md to the vault root and try again."
  exit 1
fi

if [ -f "$VAULT/index.md" ]; then
  cp "$VAULT/index.md" "$CONTENT/index.md"
else
  echo "ERROR: index.md missing from vault root at $VAULT/index.md"
  echo "Refusing to complete sync — this would ship a homepage-less wiki to production."
  echo "Restore index.md to the vault root and try again."
  exit 1
fi

# Remove excluded items that may have been pulled in transitively
for excl in "Concept Template.md"; do
  find "$CONTENT" -name "$excl" -delete
done

# Site-root technical files (robots.txt, llms.txt) — these are NOT wiki content,
# they live in the quartz repo itself (site-root/) and are re-copied into
# content/ on every sync so they survive the content wipe above and are
# emitted at the site root by the Assets() plugin.
SITE_ROOT="$HOME/quartz/site-root"
if [ -d "$SITE_ROOT" ]; then
  for f in "$SITE_ROOT"/*; do
    [ -f "$f" ] && cp "$f" "$CONTENT/$(basename "$f")"
  done
  echo "  Copied site-root technical files: $(ls "$SITE_ROOT" | tr '\n' ' ')"
fi

MD_COUNT=$(find "$CONTENT" -name '*.md' | wc -l | tr -d ' ')
IMG_COUNT=$(find "$CONTENT" \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | wc -l | tr -d ' ')
echo "Sync complete: $MD_COUNT markdown files, $IMG_COUNT image files."

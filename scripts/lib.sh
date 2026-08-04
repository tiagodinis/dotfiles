#!/usr/bin/env bash
# Shared helpers for the dotfiles save/restore runners.
# Sources scripts/detect.sh + the matching per-OS paths.sh, then exposes the
# cross-platform app functions (VS Code, Obsidian, Copilot). Lane-specific
# targets live in scripts/mac.sh and scripts/omarchy.sh.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLATFORM="$(bash "$REPO_DIR/scripts/detect.sh")"

case "$PLATFORM" in
  mac)   . "$REPO_DIR/scripts/mac/paths.sh" ;;
  linux) . "$REPO_DIR/scripts/linux/paths.sh" ;;
  *) echo "❌ Unsupported platform: $PLATFORM (only mac/linux wired so far)" >&2; exit 1 ;;
esac

# GitHub Copilot user-profile customizations (same location on mac & linux)
COPILOT_USER_DIR="$HOME/.copilot"

# ---- VS Code ---------------------------------------------------------------
vscode_restore() {
  mkdir -p "$CODE_USER_DIR"
  cp "$REPO_DIR/VSCode/settings.json" "$CODE_USER_DIR/settings.json"
  cp "$REPO_DIR/VSCode/keybindings.json" "$CODE_USER_DIR/keybindings.json"
  if command -v code >/dev/null 2>&1; then
    echo "📦 Installing VS Code extensions from extensions.txt…"
    xargs -n1 code --install-extension < "$REPO_DIR/VSCode/extensions.txt"
  else
    echo "⚠️  'code' not on PATH — skipped extension install (config still copied)"
  fi
}

vscode_save() {
  mkdir -p "$REPO_DIR/VSCode"
  cp "$CODE_USER_DIR/settings.json" "$REPO_DIR/VSCode/settings.json"
  cp "$CODE_USER_DIR/keybindings.json" "$REPO_DIR/VSCode/keybindings.json"
  if command -v code >/dev/null 2>&1; then
    code --list-extensions > "$REPO_DIR/VSCode/extensions.txt"
  fi
}

# ---- Obsidian --------------------------------------------------------------
# Secrets to blank in the repo copy: "<path relative to .obsidian>|<jq expression>".
OBSIDIAN_SECRET_FIELDS=(
  "plugins/share-note/data.json|.apiKey"
)

# Blank each configured secret in the repo copy, leaving everything else intact.
_obsidian_blank_secrets() {
  local entry rel expr file tmp
  for entry in "${OBSIDIAN_SECRET_FIELDS[@]}"; do
    rel="${entry%%|*}"; expr="${entry##*|}"
    file="$REPO_DIR/.obsidian/$rel"
    if [[ ! -f "$file" ]]; then
      continue
    fi
    tmp="$(mktemp)"
    if jq "$expr = \"\"" "$file" > "$tmp" 2>/dev/null; then
      chmod --reference="$file" "$tmp" 2>/dev/null || true
      mv "$tmp" "$file"
    else
      rm -f "$tmp"
      echo "⚠️  Could not blank $expr in $rel — check it before committing" >&2
    fi
  done
}

obsidian_restore() {
  mkdir -p "$OBSIDIAN_VAULT_DIR"
  rm -rf "$OBSIDIAN_VAULT_DIR/.obsidian"
  cp -r "$REPO_DIR/.obsidian" "$OBSIDIAN_VAULT_DIR/.obsidian"
}

obsidian_save() {
  mkdir -p "$REPO_DIR"
  rm -rf "$REPO_DIR/.obsidian"
  cp -r "$OBSIDIAN_VAULT_DIR/.obsidian" "$REPO_DIR/.obsidian"
  _obsidian_blank_secrets
}

# ---- Copilot agents & skills -------------------------------------------------
# Mirrors the repo into the user profile: replaces agents/ and skills/ wholesale,
# so renamed or deleted agents/skills never linger. Anything hand-added inside
# those two folders is overwritten — keep personal work in the repo.
copilot_restore() {
  for d in agents skills; do
    rm -rf "${COPILOT_USER_DIR:?}/$d"   # :? guard so an empty var can't mean "/agents"
    mkdir -p "$COPILOT_USER_DIR/$d"
  done
  cp "$REPO_DIR"/copilot/agents/*.agent.md "$COPILOT_USER_DIR/agents/" 2>/dev/null || true
  cp -r "$REPO_DIR"/copilot/skills/. "$COPILOT_USER_DIR/skills/" 2>/dev/null || true
}

copilot_save() {
  mkdir -p "$REPO_DIR/copilot/agents"
  cp "$COPILOT_USER_DIR"/agents/*.agent.md "$REPO_DIR/copilot/agents/" 2>/dev/null || true
  mkdir -p "$REPO_DIR/copilot/skills"
  cp -r "$COPILOT_USER_DIR"/skills/. "$REPO_DIR/copilot/skills/" 2>/dev/null || true
}

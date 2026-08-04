#!/usr/bin/env bash
# macOS lane bootstrap — invoked by the root bootstrap.sh on a Mac.
# Idempotent: safe to re-run. Honours DRY_RUN=1 (preview) and ASSUME_YES=1.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=bootstrap-lib.sh
. "$REPO_DIR/scripts/bootstrap-lib.sh"

BOOTSTRAP_USAGE="$(cat <<'EOF'
Usage: scripts/mac/bootstrap.sh [--dry-run] [--yes]

  --dry-run, -n   print the steps without changing anything
  --yes, -y       accepted for symmetry (nothing prompts in the mac lane)
EOF
)"
bootstrap_parse_args "$@"

run() { bootstrap_run "$@"; }

echo "🚀 macOS bootstrap"

# ---- 1. Homebrew -----------------------------------------------------------
if command -v brew >/dev/null 2>&1; then
  echo "🍺 Homebrew already installed"
else
  echo "🍺 Installing Homebrew…"
  if [ "${DRY_RUN:-0}" = 1 ]; then
    echo "   [dry-run] install Homebrew"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Make brew available in this shell (Apple Silicon location).
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ---- 2. GitHub CLI ---------------------------------------------------------
if command -v gh >/dev/null 2>&1; then
  echo "🔑 GitHub CLI already installed"
else
  run brew install gh
fi
# Not fatal: the root shim clones with git, so gh is only needed to push.
if command -v gh >/dev/null 2>&1 && ! gh auth status >/dev/null 2>&1; then
  echo "⚠️  gh is not authenticated — run 'gh auth login' when you want to push."
fi

# ---- 3. Packages, casks and VS Code extensions -----------------------------
echo "📦 Installing the Brewfile…"
run brew bundle --file="$REPO_DIR/Brewfile"

# Fresh casks can start with a corrupt Chrome Local State / bogus startup tabs.
echo "🔧 Clearing Chrome's initial state cache…"
run rm -f "$HOME/Library/Application Support/Google/Chrome/Local State"

# ---- 4. Node ---------------------------------------------------------------
echo "🟢 Setting up Node via nvm…"
export NVM_DIR="$HOME/.nvm"
run mkdir -p "$NVM_DIR"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  # nvm.sh is not set -u safe.
  set +u
  # shellcheck disable=SC1091
  . "/opt/homebrew/opt/nvm/nvm.sh"
  set -u
  run nvm install --lts || true
  run nvm use --lts || true
else
  echo "⚠️  nvm not found at /opt/homebrew/opt/nvm — skipping Node setup."
fi

# ---- 5. Configs ------------------------------------------------------------
echo "🔄 Restoring the mac lane (repo → live; overwrites the files it manages)…"
run bash "$REPO_DIR/scripts/dotfiles.sh" restore mac

cat <<'EOF'

✨ macOS bootstrap complete. Manual steps left:
   1. Open Obsidian and enable Community Plugins
   2. Restart iTerm2 (Cmd + Q)
EOF

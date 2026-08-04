#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/Projects/dotfiles"

# ---- Make sure the checkout exists -----------------------------------------
if [ -d "$DOTFILES_DIR/.git" ]; then
  echo "📁 Using the existing checkout at $DOTFILES_DIR"
else
  if ! command -v git >/dev/null 2>&1; then
    echo "❌ git is required to clone the repo. Install it and re-run:" >&2
    echo "   macOS: xcode-select --install    Arch: sudo pacman -S git" >&2
    exit 1
  fi
  echo "📁 Cloning dotfiles into $DOTFILES_DIR…"
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone https://github.com/tiagodinis/dotfiles.git "$DOTFILES_DIR"
fi

# ---- Flags (the helper lives in the repo, which now exists) ----------------
. "$DOTFILES_DIR/scripts/bootstrap-lib.sh"

BOOTSTRAP_USAGE="$(cat <<'EOF'
Usage: bootstrap.sh [--dry-run] [--yes]

  --dry-run, -n   print the steps without changing anything
  --yes, -y       assume yes for the Omarchy removal prompt

The lane is picked from the platform: scripts/mac or scripts/linux.
EOF
)"
bootstrap_parse_args "$@"

# ---- Hand off to the lane --------------------------------------------------
PLATFORM="$(bash "$DOTFILES_DIR/scripts/detect.sh")"

case "$PLATFORM" in
  mac)   exec bash "$DOTFILES_DIR/scripts/mac/bootstrap.sh" "$@" ;;
  linux) exec bash "$DOTFILES_DIR/scripts/linux/bootstrap.sh" "$@" ;;
  *) echo "❌ Unsupported platform: $PLATFORM (only mac/linux wired so far)" >&2; exit 1 ;;
esac

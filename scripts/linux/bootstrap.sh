#!/usr/bin/env bash
# Linux (Arch + Omarchy) lane bootstrap — invoked by the root bootstrap.sh.
# Mirrors omarchy/README.md: drop the Omarchy defaults this setup doesn't
# want, add what it does, then restore the omarchy lane.
# Idempotent: safe to re-run. Honours DRY_RUN=1 (preview) and ASSUME_YES=1.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=bootstrap-lib.sh
. "$REPO_DIR/scripts/bootstrap-lib.sh"

BOOTSTRAP_USAGE="$(cat <<'EOF'
Usage: scripts/linux/bootstrap.sh [--dry-run] [--yes]

  --dry-run, -n   print the steps without changing anything
  --yes, -y       apply the removals without asking
EOF
)"
bootstrap_parse_args "$@"

run() { bootstrap_run "$@"; }

if ! command -v pacman >/dev/null 2>&1; then
  echo "❌ pacman not found — this lane expects Arch/Omarchy." >&2
  exit 1
fi

have_omarchy=0
command -v omarchy >/dev/null 2>&1 && have_omarchy=1

echo "🚀 Omarchy bootstrap"
if [ "$have_omarchy" = 0 ]; then
  echo "⚠️  'omarchy' CLI not found — package add/drop steps will be skipped."
fi

# ---- 1. Remove the unwanted Omarchy defaults -------------------------------
# Base packages Omarchy ships that this setup drops (see omarchy/README.md).
DROP_PKGS="cliamp moonlight-qt obs-studio xournalpp"

# `pacman -Qtdq` is machine-wide (not just what these removals leave behind),
# so surface it in the summary before anything is uninstalled.
ORPHANS="$(pacman -Qtdq 2>/dev/null || true)"

echo
echo "🧹 Removals: webapp launchers, $DROP_PKGS, Voxtype."
if [ -n "$ORPHANS" ]; then
  echo "   Orphaned deps: $ORPHANS"
fi

if [ "${ASSUME_YES:-0}" = 1 ]; then
  :
elif [ -r /dev/tty ]; then
  # Read from the tty so this also works when the shim came in via `curl | bash`.
  printf "   Proceed with removals? [y/N] "
  read -r reply < /dev/tty || reply=""
  case "$reply" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "   Skipped removals."; SKIP_REMOVALS=1 ;;
  esac
else
  echo "   Non-interactive shell — skipping removals (use --yes to apply)."
  SKIP_REMOVALS=1
fi

if [ "${SKIP_REMOVALS:-0}" != 1 ]; then
  if [ "$have_omarchy" = 1 ]; then
    run omarchy-webapp-remove-all
    # shellcheck disable=SC2086  # intentional word splitting of the package list
    run omarchy pkg drop $DROP_PKGS
  fi
  run rm -rf "$HOME/.config/xournalpp"

  # Voxtype + its custom wiring; scripted and idempotent (scripts/omarchy.sh).
  run bash "$REPO_DIR/scripts/omarchy.sh" prune voxtype

  # Dependencies orphaned on this machine (listed in the summary above).
  # shellcheck disable=SC2086  # intentional word splitting of the package list
  if [ -n "$ORPHANS" ]; then
    run sudo pacman -Rns --noconfirm $ORPHANS
  fi
fi

# ---- 2. Install what Omarchy doesn't ship ----------------------------------
echo
echo "📦 Installs: handy-bin + google-chrome (AUR), firefox (extra)."
if [ "$have_omarchy" = 1 ]; then
  run omarchy pkg aur add handy-bin google-chrome
  run omarchy pkg add firefox
elif command -v yay >/dev/null 2>&1; then
  run yay -S --noconfirm handy-bin google-chrome
  run sudo pacman -S --noconfirm firefox
else
  echo "⚠️  neither 'omarchy' nor 'yay' is available — install manually:"
  echo "    yay -S handy-bin google-chrome && sudo pacman -S firefox"
fi

# ---- 3. Configs ------------------------------------------------------------
echo
echo "🔄 Restoring the omarchy lane (repo → live; overwrites the files it manages)…"
run bash "$REPO_DIR/scripts/dotfiles.sh" restore omarchy

cat <<'EOF'

✨ Omarchy bootstrap complete. Manual steps left:
   1. Handy: launch it once, download a model and pick your microphone.
   2. keyd: check the [ids] blocks in omarchy/etc/keyd/*.conf match this
      hardware (sudo keyd monitor), then: hyprctl reload && hyprctl configerrors

The webapp keybindings are already unbound by omarchy/hypr/bindings.lua, which
the restore above installed — no manual hl.unbind() edits needed.
EOF

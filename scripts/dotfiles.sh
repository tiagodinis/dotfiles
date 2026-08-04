#!/usr/bin/env bash
# Unified dotfiles entry point — one action per command, lanes as arguments.
#
#   scripts/dotfiles.sh <save|restore|list> [lane] [target...]
#
#   lane    all (default) | mac | omarchy
#   target  one item inside the lane (omit it for the whole lane)
#
# From npm, arguments are forwarded straight through:
#   npm run save                       # every applicable target on this machine
#   npm run restore mac                # the whole mac lane
#   npm run restore omarchy            # the whole omarchy lane
#   npm run save omarchy hypr          # just the Hyprland files
#   npm run restore mac zsh            # just zsh
#
# Pruning (removing unwanted Omarchy software) is not a command here — it is
# part of the Omarchy bootstrap, see scripts/linux/bootstrap.sh.
#
# mac lane:      brew git zsh iterm rectangle macos vscode obsidian copilot
# omarchy lane:  git zsh vscode obsidian copilot hypr handy fcitx5 keyd
# (vscode/obsidian/copilot are shared, so they appear in both lanes.)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$REPO_DIR/scripts/lib.sh"   # shared apps (vscode/obsidian/copilot) + REPO_DIR/PLATFORM
. "$REPO_DIR/scripts/mac.sh"   # mac lane targets

# Ordered registry per lane: shared apps first, then lane-specific targets.
TARGETS_ALL="git zsh vscode obsidian copilot brew iterm rectangle macos hypr handy fcitx5 keyd"
TARGETS_MAC="git zsh vscode obsidian copilot brew iterm rectangle macos"
TARGETS_OMARCHY="git zsh vscode obsidian copilot hypr handy fcitx5 keyd"

usage() {
  cat <<'EOF'
Usage: npm run <save|restore> [lane] [target...]
       bash scripts/dotfiles.sh <save|restore|list> [lane] [target...]

  lane    all (default) | mac | omarchy
  target  a single item from the lane (omit it for the whole lane)

  mac lane:      brew git zsh iterm rectangle macos vscode obsidian copilot
  omarchy lane:  git zsh vscode obsidian copilot hypr handy fcitx5 keyd

Examples:
  npm run save                    save every applicable target on this machine
  npm run restore mac             restore the whole mac lane
  npm run restore omarchy         restore the whole omarchy lane
  npm run save omarchy hypr       save only the Hyprland files
  npm run restore mac zsh         restore only zsh
  bash scripts/dotfiles.sh list   print the target registry
EOF
}

ACTION="${1:-help}"; shift || true

# A leading lane name picks the lane; anything else is a target (lane stays all).
LANE="all"
case "${1:-}" in
  mac|omarchy|all) LANE="$1"; shift ;;
esac
REQUESTED=("$@")

# shellcheck disable=SC2206  # intentional word splitting of the registries
case "$LANE" in
  all)     LANE_TARGETS=($TARGETS_ALL) ;;
  mac)     LANE_TARGETS=($TARGETS_MAC) ;;
  omarchy) LANE_TARGETS=($TARGETS_OMARCHY) ;;
esac

in_list() {
  local needle="$1"; shift
  local item
  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

run_target() {
  local action="$1" target="$2"
  # Functions are named "<target>_<action>" (git_save, iterm_restore, …).
  local fn="${target}_${action}"
  case "$target" in
    hypr|handy|fcitx5|keyd)
      bash "$REPO_DIR/scripts/omarchy.sh" "$action" "$target" ;;
    *)
      if declare -F "$fn" >/dev/null; then
        "$fn"
      else
        echo "⏭️  $target: no '$action' step — skipped."
      fi ;;
  esac
}

# Pruning lives in the Omarchy bootstrap (scripts/linux/bootstrap.sh), not here.
case "$ACTION" in
  save|restore) ;;
  list)
    echo "lane=all      : $TARGETS_ALL"
    echo "lane=mac      : $TARGETS_MAC"
    echo "lane=omarchy  : $TARGETS_OMARCHY"
    exit 0 ;;
  help|-h|--help)
    usage
    exit 0 ;;
  *)
    usage >&2
    exit 1 ;;
esac

# Validate requested targets, then run them in lane order (brew before apps, …).
if [ "${#REQUESTED[@]}" -gt 0 ]; then
  for r in "${REQUESTED[@]}"; do
    if ! in_list "$r" "${LANE_TARGETS[@]}"; then
      echo "❌ unknown target '$r' for lane '$LANE'." >&2
      echo "   valid targets: ${LANE_TARGETS[*]}" >&2
      exit 1
    fi
  done
fi

TARGETS=()
for t in "${LANE_TARGETS[@]}"; do
  if [ "${#REQUESTED[@]}" -eq 0 ] || in_list "$t" "${REQUESTED[@]}"; then
    TARGETS+=("$t")
  fi
done

echo "🔄 $ACTION · lane=$LANE · $PLATFORM · ${#TARGETS[@]} target(s)"
for target in "${TARGETS[@]}"; do
  echo "── $ACTION:$target"
  run_target "$ACTION" "$target"
done
echo "✨ $ACTION complete (lane=$LANE)."

#!/usr/bin/env bash
# Omarchy (Linux/Arch + Hyprland) lane — per-target save/restore for:
#   hypr    ~/.config/hypr/{hyprland,bindings,input,monitors}.lua + handy-ptt.sh
#   fcitx5  ~/.config/fcitx5/conf/quickphrase.conf
#   keyd    /etc/keyd/{default,magic}.conf (restore needs sudo)
#   handy   Handy app settings — only the keys listed in omarchy/handy/settings.json
#           (that file is hand-maintained, so save_handy is a no-op)
#   voxtype prune-only: remove the unwanted Voxtype dictation leftovers
# Prune removes unwanted stock/optional software — see omarchy/README.md.
# A full restore also prunes it.
#
# Usage: bash scripts/omarchy.sh save|restore|prune [hypr|fcitx5|keyd|handy|voxtype|all]
# Called by scripts/dotfiles.sh; safe to run directly too.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTION="${1:-}"
TARGET="${2:-all}"

if [ "$(uname -s)" != "Linux" ]; then
  echo "ℹ️  omarchy lane is Linux-only — skipping ($ACTION)."
  exit 0
fi

HYPR_SRC="$HOME/.config/hypr"
FCITX_SRC="$HOME/.config/fcitx5/conf"
HANDY_DIR="$HOME/.local/share/com.pais.handy"
HANDY_STORE="$HANDY_DIR/settings_store.json"
HANDY_DESIRED="$REPO_DIR/omarchy/handy/settings.json"

# ---- save ------------------------------------------------------------------
save_hypr() {
  mkdir -p "$REPO_DIR/omarchy/hypr"
  for f in hyprland.lua bindings.lua input.lua monitors.lua handy-ptt.sh; do
    if [ -f "$HYPR_SRC/$f" ]; then
      cp "$HYPR_SRC/$f" "$REPO_DIR/omarchy/hypr/$f"
    fi
  done
}

save_fcitx5() {
  mkdir -p "$REPO_DIR/omarchy/fcitx5/conf"
  if [ -f "$FCITX_SRC/quickphrase.conf" ]; then
    cp "$FCITX_SRC/quickphrase.conf" "$REPO_DIR/omarchy/fcitx5/conf/quickphrase.conf"
  fi
}

save_keyd() {
  # /etc/keyd/*.conf are root-owned but world-readable (0644), so no sudo to save.
  mkdir -p "$REPO_DIR/omarchy/etc/keyd"
  for f in default.conf magic.conf; do
    if [ -r "/etc/keyd/$f" ]; then
      cp "/etc/keyd/$f" "$REPO_DIR/omarchy/etc/keyd/$f"
    fi
  done
}

save_handy() {
  echo "ℹ️  handy: keys are hand-maintained in omarchy/handy/settings.json — nothing to save."
}

# Remove Voxtype (dictation) and every leftover it leaves behind: the custom
# autostart unit, the post-update install-nag hook, user config/models, the
# package itself, and the system config. Idempotent — safe to run repeatedly.
remove_voxtype() {
  systemctl --user disable --now voxtype.service 2>/dev/null || true
  rm -f "$HOME/.config/systemd/user/voxtype.service"
  systemctl --user daemon-reload 2>/dev/null || true
  rm -f "$HOME/.config/omarchy/hooks/post-update.d/install-voxtype.hook"
  rm -f "$HOME/.local/state/omarchy/done/voxtype-install-invitation"
  rm -rf "$HOME/.config/voxtype" "$HOME/.local/share/voxtype" "$HOME/.cache/voxtype"

  if pacman -Qq voxtype-bin >/dev/null 2>&1; then
    if sudo -n true 2>/dev/null; then
      sudo pacman -Rns --noconfirm voxtype-bin
      sudo rm -rf /etc/voxtype
      echo "🧹 Voxtype removed."
    else
      echo "⚠️  Voxtype package removal needs sudo — run:"
      echo "    sudo pacman -Rns --noconfirm voxtype-bin"
      echo "    sudo rm -rf /etc/voxtype"
    fi
  fi
}

# Handy keeps its settings in a tauri store that caches them in memory, so the
# values must be written while the app is stopped (and the app restarted after).
# A fresh install otherwise comes up with paste_method=direct, which drops
# keystrokes inside VS Code — see omarchy/handy/settings.json and omarchy/README.md.
restore_handy() {
  [ -f "$HANDY_DESIRED" ] || return 0
  if ! command -v handy >/dev/null 2>&1; then
    echo "ℹ️  handy not installed — skipping its settings."
    return 0
  fi

  if [ ! -f "$HANDY_STORE" ]; then
    mkdir -p "$HANDY_DIR"
    printf '{\n    "settings": {}\n}\n' > "$HANDY_STORE"
    echo "   created $HANDY_STORE (Handy had not run yet)"
  fi

  local was_running=""
  if pgrep -x handy >/dev/null 2>&1; then
    was_running="yes"
    pkill -x handy && sleep 1
  fi

  cp "$HANDY_STORE" "$HANDY_STORE.bak-$(date +%s)"
  # keep only the 3 newest backups
  ls -1t "$HANDY_STORE".bak-* 2>/dev/null | tail -n +4 | while read -r old; do
    rm -f "$old"
  done || true

  if python3 "$REPO_DIR/omarchy/handy/apply-settings.py" "$HANDY_STORE" "$HANDY_DESIRED"; then
    echo "   Handy settings applied."
  else
    echo "⚠️  could not apply Handy settings — previous file kept as $HANDY_STORE.bak-*"
  fi

  if [ -n "$was_running" ]; then
    setsid handy >/dev/null 2>&1 &
    echo "   Handy restarted."
  fi
}

# ---- restore ---------------------------------------------------------------
restore_hypr() {
  mkdir -p "$HYPR_SRC"
  for f in hyprland.lua bindings.lua input.lua monitors.lua handy-ptt.sh; do
    if [ -f "$REPO_DIR/omarchy/hypr/$f" ]; then
      cp "$REPO_DIR/omarchy/hypr/$f" "$HYPR_SRC/$f"
    fi
  done
  if [ -f "$HYPR_SRC/handy-ptt.sh" ]; then
    chmod +x "$HYPR_SRC/handy-ptt.sh"
  fi
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
}

restore_fcitx5() {
  mkdir -p "$FCITX_SRC"
  if [ -f "$REPO_DIR/omarchy/fcitx5/conf/quickphrase.conf" ]; then
    cp "$REPO_DIR/omarchy/fcitx5/conf/quickphrase.conf" "$FCITX_SRC/quickphrase.conf"
  fi
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user restart omarchy-fcitx5.service 2>/dev/null || true
  fi
}

restore_keyd() {
  # keyd configs live in /etc (root) — needs sudo (or passwordless sudo).
  if ! ls "$REPO_DIR"/omarchy/etc/keyd/*.conf >/dev/null 2>&1; then
    echo "ℹ️  keyd: no saved configs in omarchy/etc/keyd — skipped."
    return 0
  fi
  if sudo -n true 2>/dev/null; then
    for f in "$REPO_DIR"/omarchy/etc/keyd/*.conf; do
      sudo install -m 644 "$f" /etc/keyd/"$(basename "$f")"
    done
    sudo systemctl restart keyd 2>/dev/null || true
    echo "   keyd configs restored."
  else
    echo "⚠️  keyd restore needs sudo — run:"
    for f in "$REPO_DIR"/omarchy/etc/keyd/*.conf; do
      echo "    sudo install -m 644 $f /etc/keyd/$(basename "$f")"
    done
    echo "    sudo systemctl restart keyd"
  fi
}

case "$ACTION" in
  save)
    case "$TARGET" in
      all) for t in hypr fcitx5 keyd handy; do "save_$t"; done ;;
      hypr|fcitx5|keyd|handy) "save_$TARGET" ;;
      *) echo "❌ omarchy: cannot save '$TARGET'" >&2; exit 1 ;;
    esac
    echo "💾 omarchy config saved ($TARGET)."
    ;;
  restore)
    case "$TARGET" in
      all)
        for t in hypr fcitx5 keyd handy; do "restore_$t"; done
        remove_voxtype
        ;;
      hypr|fcitx5|keyd|handy) "restore_$TARGET" ;;
      *) echo "❌ omarchy: cannot restore '$TARGET'" >&2; exit 1 ;;
    esac
    echo "🔄 omarchy config restored ($TARGET)."
    ;;
  prune)
    case "$TARGET" in
      all|voxtype) remove_voxtype ;;
      *) echo "❌ omarchy: cannot prune '$TARGET'" >&2; exit 1 ;;
    esac
    echo "🧹 Pruned unwanted Omarchy software."
    ;;
  *)
    echo "usage: bash scripts/omarchy.sh save|restore|prune [hypr|fcitx5|keyd|handy|voxtype|all]" >&2
    exit 1
    ;;
esac

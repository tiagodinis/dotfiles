#!/usr/bin/env bash
# Mac lane targets — brew, git, zsh, iTerm2, Rectangle, macOS defaults.
# Sourced by scripts/dotfiles.sh, which supplies REPO_DIR/PLATFORM from lib.sh.
set -euo pipefail

if [ -z "${REPO_DIR:-}" ]; then
  . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
fi

is_mac() { [ "$PLATFORM" = mac ]; }
skip_mac_only() { echo "⏭️  $1: macOS only — skipped on $PLATFORM."; return 0; }

# ---- brew (restore only; Brewfile is hand-maintained) ----------------------
brew_save() {
  echo "ℹ️  brew: Brewfile is hand-maintained — nothing to save."
}

brew_restore() {
  if command -v brew >/dev/null 2>&1; then
    brew bundle --file="$REPO_DIR/Brewfile"
  else
    echo "⚠️  brew not installed — skipped Brewfile restore."
  fi
}

# ---- git -------------------------------------------------------------------
git_save() {
  mkdir -p "$REPO_DIR/git"
  cp "$HOME/.gitconfig" "$REPO_DIR/git/.gitconfig" 2>/dev/null || true
}

git_restore() {
  cp "$REPO_DIR/git/.gitconfig" "$HOME/.gitconfig" 2>/dev/null || true
}

# ---- zsh -------------------------------------------------------------------
setup_zsh_plugins() {
  local p10k="$HOME/.powerlevel10k"
  local autosugg="$HOME/.zsh/zsh-autosuggestions"
  local syntax="$HOME/.zsh/zsh-syntax-highlighting"

  if [ ! -d "$p10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k"
  fi
  if [ ! -d "$autosugg" ]; then
    mkdir -p "$(dirname "$autosugg")"
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$autosugg"
  fi
  if [ ! -d "$syntax" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax"
  fi
}

zsh_save() {
  mkdir -p "$REPO_DIR/zsh"
  cp "$HOME/.zshrc" "$REPO_DIR/zsh/.zshrc" 2>/dev/null || true
  cp "$HOME/.p10k.zsh" "$REPO_DIR/zsh/.p10k.zsh" 2>/dev/null || true
}

zsh_restore() {
  setup_zsh_plugins
  cp "$REPO_DIR/zsh/.zshrc" "$HOME/.zshrc" 2>/dev/null || true
  cp "$REPO_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh" 2>/dev/null || true
}

# ---- mac-only app configs --------------------------------------------------
iterm_save() {
  is_mac || { skip_mac_only iterm; return 0; }
  mkdir -p "$REPO_DIR/iterm2"
  cp "$HOME/Library/Preferences/com.googlecode.iterm2.plist" "$REPO_DIR/iterm2/" 2>/dev/null || true
}

iterm_restore() {
  is_mac || { skip_mac_only iterm; return 0; }
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$REPO_DIR/iterm2"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
}

rectangle_save() {
  is_mac || { skip_mac_only rectangle; return 0; }
  mkdir -p "$REPO_DIR/rectangle"
  defaults export com.knollsoft.Rectangle "$REPO_DIR/rectangle/com.knollsoft.Rectangle.plist" 2>/dev/null || true
}

rectangle_restore() {
  is_mac || { skip_mac_only rectangle; return 0; }
  killall Rectangle 2>/dev/null || true
  defaults import com.knollsoft.Rectangle "$REPO_DIR/rectangle/com.knollsoft.Rectangle.plist"
  open -a Rectangle 2>/dev/null || true
}

macos_save() {
  is_mac || { skip_mac_only macos; return 0; }
  mkdir -p "$REPO_DIR/macos"
  defaults read com.apple.dock autohide-delay > "$REPO_DIR/macos/dock-delay" 2>/dev/null || true
}

macos_restore() {
  is_mac || { skip_mac_only macos; return 0; }
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0
  killall Dock 2>/dev/null || true
}

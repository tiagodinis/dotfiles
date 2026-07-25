#!/usr/bin/env bash

set -e

echo "🚀 Starting macOS Bootstrap..."

# 1. Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Install GitHub CLI if not present, then clone dotfiles
if ! command -v gh &> /dev/null; then
    echo "🔑 Installing GitHub CLI..."
    brew install gh
fi

# Ensure gh is authenticated before cloning
if ! gh auth status &> /dev/null 2>&1; then
    echo "🔐 Please authenticate with GitHub first, then re-run this script:"
    echo "   gh auth login"
    exit 1
fi

DOTFILES_DIR="$HOME/Projects/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📁 Cloning dotfiles repository..."
    mkdir -p "$HOME/Projects"
    gh repo clone tiagodinis/dotfiles "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

# 3. Restore Brew packages (installs Git, gh, Node, iTerm2, VS Code, Fonts)
echo "📦 Restoring Homebrew packages..."
brew bundle --file=./Brewfile

# Fix potential Google Chrome Local State/startup tab corruption from fresh casks
echo "🔧 Cleaning up Chrome initial state cache..."
rm -f ~/Library/Application\ Support/Google/Chrome/Local\ State

# 4. Install LTS Node via NVM
echo "🟢 Setting up Node.js..."
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
nvm install --lts || true
nvm use --lts || true

# 5. Run Dotfiles Restorations
echo "🔄 Restoring configurations..."
npm run restore-all

echo "✨ Bootstrap complete! Remaining manual steps:"
echo "1. Open Obsidian and enable Community Plugins"
echo "2. Restart iTerm2 (Cmd + Q)"
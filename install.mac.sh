#!/bin/bash
# ==============================================================================
# macOS Dotfiles Installer
# ==============================================================================

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "   Deploying macOS Environment            "
echo "=========================================="

# ------------------------------------------------------------------------------
# 1. 建立 Vim 設定檔軟連結 -> dotfiles/vim
# ------------------------------------------------------------------------------
mkdir -p "$HOME/.vim"
ln -sf "$DOTFILES/vim/.vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES/vim/autoload" "$HOME/.vim/autoload"
echo "[+] Symlink created: ~/.vimrc & ~/.vim/autoload"

# ------------------------------------------------------------------------------
# 2. 建立 Kanata 鍵盤配置軟連結 -> ~/.config/kanata/kanata.kbd
# ------------------------------------------------------------------------------
if [ -f "$DOTFILES/kanata/kanata.kbd" ]; then
    mkdir -p "$HOME/.config/kanata"
    ln -sf "$DOTFILES/kanata/kanata.kbd" "$HOME/.config/kanata/kanata.kbd"
    echo "[+] Symlink created: ~/.config/kanata/kanata.kbd"
fi

# ------------------------------------------------------------------------------
# 3. 部署並載入 launchd plist 背景服務
# ------------------------------------------------------------------------------
if [ -d "$DOTFILES/mac" ]; then
    mkdir -p "$HOME/Library/LaunchAgents"
    for plist in "$DOTFILES/mac/"*.plist; do
        [ -f "$plist" ] || continue
        filename=$(basename "$plist")
        target_link="$HOME/Library/LaunchAgents/$filename"
        
        # 建立軟連結
        ln -sf "$plist" "$target_link"
        echo "[+] Symlink created: LaunchAgent -> $filename"

        # 自動 unload 舊服務並重新 load 新服務
        launchctl unload "$target_link" 2>/dev/null || true
        launchctl load "$target_link"
        echo "[+] LaunchAgent loaded: $filename"
    done
fi

# ------------------------------------------------------------------------------
# 4. 透過 Homebrew 自動安裝 CLI 工具與 Cask 應用程式
# ------------------------------------------------------------------------------
if command -v brew &> /dev/null; then
    echo "------------------------------------------"
    echo "[+] Checking macOS dependencies via Homebrew..."

    # 1. GUI 應用程式 (Cask)
    if ! brew list --cask karabiner-elements &> /dev/null; then
        echo "[+] Installing Karabiner-Elements..."
        brew install --cask karabiner-elements
    else
        echo "[=] Karabiner-Elements is already installed."
    fi

    # 2. CLI 工具 (Kanata, ripgrep, universal-ctags, macism)
    command -v kanata &> /dev/null || { echo "[+] Installing kanata..."; brew install kanata; }
    command -v rg &> /dev/null || { echo "[+] Installing ripgrep..."; brew install ripgrep; }
    command -v ctags &> /dev/null || { echo "[+] Installing universal-ctags..."; brew install universal-ctags; }
    command -v macism &> /dev/null || { echo "[+] Installing macism..."; brew tap laishulu/macism && brew install macism; }
else
    echo "[-] Homebrew not found. Please install Homebrew first."
fi

# ------------------------------------------------------------------------------
# 5. 自動檢測與安裝 uv
# ------------------------------------------------------------------------------
if ! command -v uv &> /dev/null; then
    echo "[+] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "[=] uv is already installed, skipping."
fi

echo "------------------------------------------"
echo ">>> macOS deployment finished!"
echo "=========================================="

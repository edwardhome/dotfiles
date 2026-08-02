#!/bin/bash
# ==============================================================================
# Linux / Ubuntu Dotfiles Installer
# ==============================================================================

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "   Deploying Linux / Ubuntu Environment   "
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
# 3. 部署 Systemd User Service 背景服務 (如果有放 linux/ 目錄)
# ------------------------------------------------------------------------------
if [ -d "$DOTFILES/linux/systemd" ]; then
    mkdir -p "$HOME/.config/systemd/user"
    for service in "$DOTFILES/linux/systemd/"*.* ; do
        [ -f "$service" ] || continue
        filename=$(basename "$service")
        target_link="$HOME/.config/systemd/user/$filename"
        
        ln -sf "$service" "$target_link"
        echo "[+] Symlink created: systemd user service -> $filename"
    done

    # 重新載入並啟用服務
    if command -v systemctl &> /dev/null; then
        systemctl --user daemon-reload || true
        echo "[+] Executed: systemctl --user daemon-reload"
    fi
fi

# ------------------------------------------------------------------------------
# 4. 透過 apt 自動安裝基礎 CLI 工具 (ripgrep, universal-ctags)
# ------------------------------------------------------------------------------
if command -v apt-get &> /dev/null; then
    echo "------------------------------------------"
    echo "[+] Checking Ubuntu dependencies via apt..."
    
    # 檢查是否需要 sudo 安裝缺失工具
    MISSING_PKGS=()
    command -v rg &> /dev/null || MISSING_PKGS+=("ripgrep")
    command -v ctags &> /dev/null || MISSING_PKGS+=("universal-ctags")

    if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
        echo "[+] Installing missing packages: ${MISSING_PKGS[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y "${MISSING_PKGS[@]}"
    else
        echo "[=] Base CLI tools (rg, ctags) are already installed."
    fi
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
echo ">>> Linux / Ubuntu deployment finished!"
echo "=========================================="

# dotfiles
存放個人專用的電腦設定檔與離線自動化部署腳本。

## 📂 資料夾結構

```text
.
├── bin
│   └── win
│       ├── ctags.exe
│       ├── im-select.exe
│       ├── mingw64
│       └── rg.exe
├── install.linux.sh
├── install.mac.sh
├── install.ps1
├── kanata
│   ├── kanata.kbd
│   ├── linux
│   │   └── linux-binaries-x64.zip
│   ├── mac
│   │   ├── Karabiner-Elements-15.3.0.dmg
│   │   └── macos-binaries-arm64.zip
│   └── win
│       └── windows-binaries-x64.zip
├── mac
│   └── com.kanata.daemon.plist
├── README.md
├── scripts
├── ssh
└── vim
    └── autoload
        └── plug.vim
---

## 🛠️ 第三方工具與元件參考

* **im-select** (Windows 自動切換輸入法): [daipeihust/im-select](https://github.com/daipeihust/im-select)
* **macism** (macOS 自動切換輸入法): [laishulu/macism](https://github.com/laishulu/macism)
* **Universal Ctags**: [universal-ctags/ctags](https://github.com/universal-ctags/ctags)
* **ripgrep**: [BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep)
* **Kanata** (跨平台改鍵工具): [jtroo/kanata](https://github.com/jtroo/kanata)
* **Karabiner-Elements** (macOS 底層虛擬鍵盤驅動/改鍵依賴): [pqrs-org/Karabiner-Elements](https://github.com/pqrs-org/Karabiner-Elements)

---

## ⚠️ 軟體版本相容性注意事項 (Important Version Notes)

### 🍎 macOS: Karabiner-Elements & Kanata 配合

在 macOS 上使用 Kanata 攔截與映射鍵盤時，需要留意與 Karabiner-Elements 的版本契合度：

* **Karabiner-Elements**: 推薦穩定版本 **`v15.3.0`**。
* **Kanata (macOS)**: 透過 Homebrew 安裝最新 release 版本。
* **相容性提醒**: 若使用過舊或過新的 Karabiner Driver 介面，可能導致 Kanata 無法取得 `VirtualHIDDevice` 抓取鍵盤事件。透過 `install.mac.sh` 部署時請維持此版本搭配。

---

## 🪟 Windows 操作說明

請開啟 PowerShell（建議以管理員身份），切換至 `dotfiles` 目錄執行：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\install.ps1

```

> **包含動作：**
> * 建立 `%USERPROFILE%\_vimrc` 軟連結
> * 建立 `%USERPROFILE%\vimfiles\autoload` 軟連結
> * 將 `bin\win` 與 `MinGW64` 自動加入使用者 `PATH`
> * 自動檢測並下載安裝 `uv`
> 
> 

---

## 🍎 macOS 操作說明

開啟 Terminal，切換至 `dotfiles` 目錄執行：

```bash
chmod +x install.mac.sh
./install.mac.sh

```

> **包含動作：**
> * 建立 `~/.vimrc` 與 `~/.vim/autoload` 軟連結
> * 建立 `~/.config/kanata/kanata.kbd` 軟連結
> * 部署 `~/Library/LaunchAgents/com.kanata.daemon.plist` 並自動執行 `launchctl load` 背景常駐
> * 透過 Homebrew 安裝 **Karabiner-Elements (v15.3.0)**、`kanata`、`ripgrep`、`universal-ctags`、`macism` 與 `uv`
> 
> 

---

## 🐧 Linux 操作說明

開啟 Terminal，切換至 `dotfiles` 目錄執行：

```bash
chmod +x install.linux.sh
./install.linux.sh

```

> **包含動作：**
> * 建立 `~/.vimrc` 與 `~/.vim/autoload` 軟連結
> * 掛載 `~/.config/systemd/user/` 背景服務並執行 `systemctl --user daemon-reload`
> * 自動檢測並安裝 `uv`
> 
> 

---

## 🔌 Vim 套件初始化 (跨平台適用)

各平台腳本部署完畢後，開啟 Vim 執行以下指令以下載並啟用所有套件：

```vim
:PlugInstall


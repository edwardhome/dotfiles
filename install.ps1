# ==============================================================================
# Windows 自動化部署腳本 (Dotfiles Installer for Windows)
# ==============================================================================

# 設定失敗即停止，並自動抓取當前腳本所在目錄
$ErrorActionPreference = "Stop"
$Dotfiles = $PSScriptRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   開始部署 Windows 個人軟體軍火庫...   " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. 建立 .vimrc 軟連結橋接
# ------------------------------------------------------------------------------
$VimrcTarget = "$Dotfiles\vim\.vimrc"
$VimrcLink   = "$HOME\_vimrc"

if (Test-Path $VimrcTarget) {
    New-Item -ItemType SymbolicLink -Path $VimrcLink -Target $VimrcTarget -Force | Out-Null
    Write-Host "[+] 已成功建立 _vimrc 軟連結橋接" -ForegroundColor Green
} else {
    Write-Host "[-] 未找到 $VimrcTarget，請確認 vim\.vimrc 是否已放好" -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 2. 建立 .vim\autoload 軟連結 (讓 vim-plug 自動到位)
# ------------------------------------------------------------------------------
$AutoloadTarget = "$Dotfiles\vim\autoload"
$VimHomeDir     = "$HOME\.vim"

if (!(Test-Path $VimHomeDir)) {
    New-Item -ItemType Directory -Path $VimHomeDir | Out-Null
}

if (Test-Path $AutoloadTarget) {
    New-Item -ItemType SymbolicLink -Path "$VimHomeDir\autoload" -Target $AutoloadTarget -Force | Out-Null
    Write-Host "[+] 已成功建立 .vim\autoload 軟連結 (vim-plug)" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 3. 將 bin\win 工具庫與 MinGW64 自動加入使用者 PATH
# ------------------------------------------------------------------------------
$BinPaths = @(
    "$Dotfiles\bin\win",
    "$Dotfiles\bin\win\mingw64\bin"
)

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$PathUpdated = $false

foreach ($path in $BinPaths) {
    if (Test-Path $path) {
        if ($UserPath -notlike "*$path*") {
            if ([string]::IsNullOrWhiteSpace($UserPath)) {
                $UserPath = $path
            } else {
                $UserPath = "$UserPath;$path"
            }
            $PathUpdated = $true
            Write-Host "[+] 已加入 PATH: $path" -ForegroundColor Yellow
        } else {
            Write-Host "[=] 已存在於 PATH: $path" -ForegroundColor DarkGray
        }
    }
}

if ($PathUpdated) {
    [Environment]::SetEnvironmentVariable("Path", $UserPath, "User")
    Write-Host "[+] 使用者 PATH 變數已更新！" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 4. 自動檢測並安裝 uv (Python 極速環境管理工具)
# ------------------------------------------------------------------------------
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "[+] 正在安裝 uv (Python 極速環境管理工具)..." -ForegroundColor Cyan
    try {
        powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
        Write-Host "[+] uv 安裝成功！" -ForegroundColor Green
    } catch {
        Write-Host "[-] uv 安裝失敗，請稍後手動執行官方安裝命令" -ForegroundColor Red
    }
} else {
    Write-Host "[=] uv 已存在，跳過安裝" -ForegroundColor DarkGray
}

Write-Host "------------------------------------------" -ForegroundColor Cyan
Write-Host ">>> Windows 部署全部完成！" -ForegroundColor Green
Write-Host ">>> 提示：請重新開啟 PowerShell 以讓新的 PATH 環境變數生效。" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

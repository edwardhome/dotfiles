# ==============================================================================
# Windows Dotfiles Installer
# ==============================================================================

$ErrorActionPreference = "Stop"
$Dotfiles = $PSScriptRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Deploying Windows Dotfiles Environment " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. Symlink _vimrc to HOME
# ------------------------------------------------------------------------------
$VimrcTarget = "$Dotfiles\vim\.vimrc"
$VimrcLink   = "$HOME\_vimrc"

if (Test-Path $VimrcTarget) {
    New-Item -ItemType SymbolicLink -Path $VimrcLink -Target $VimrcTarget -Force | Out-Null
    Write-Host "[+] Symlink created: _vimrc -> vim\.vimrc" -ForegroundColor Green
} else {
    Write-Host "[-] $VimrcTarget not found, skipping _vimrc" -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# 2. Symlink .vim\autoload (vim-plug)
# ------------------------------------------------------------------------------
$VimHomeDir = "$HOME\vimfiles"
$AutoloadPath = "$VimHomeDir\autoload"
$AutoloadTarget = "$DOTFILES\vim\autoload"

# 確保父目錄 C:\Users\Defu\vimfiles 存在
if (-not (Test-Path $VimHomeDir)) {
    New-Item -ItemType Directory -Path $VimHomeDir -Force | Out-Null
}

# 若 C:\Users\Defu\vimfiles\autoload 已存在（無論是舊資料夾或舊連結），先強制刪除
if (Test-Path $AutoloadPath) {
    Remove-Item -Path $AutoloadPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[*] Removed existing path: $AutoloadPath"
}

# 強制建立 SymbolicLink
New-Item -ItemType SymbolicLink -Path $AutoloadPath -Target $AutoloadTarget -Force
Write-Host "[+] Symlink created: $AutoloadPath -> $AutoloadTarget"
# ------------------------------------------------------------------------------
# 3. Add bin\win and MinGW64 to User PATH
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
            Write-Host "[+] Added to PATH: $path" -ForegroundColor Yellow
        } else {
            Write-Host "[=] Already in PATH: $path" -ForegroundColor DarkGray
        }
    }
}

if ($PathUpdated) {
    [Environment]::SetEnvironmentVariable("Path", $UserPath, "User")
    Write-Host "[+] User PATH variable updated successfully!" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 4. Check and install uv
# ------------------------------------------------------------------------------
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Installing uv..." -ForegroundColor Cyan
    try {
        powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
        Write-Host "[+] uv installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "[-] Failed to install uv, please install it manually." -ForegroundColor Red
    }
} else {
    Write-Host "[=] uv already installed, skipping." -ForegroundColor DarkGray
}

Write-Host "------------------------------------------" -ForegroundColor Cyan
Write-Host ">>> Windows deployment finished!" -ForegroundColor Green
Write-Host ">>> Note: Restart PowerShell to apply PATH updates." -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

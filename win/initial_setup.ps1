#Requires -Version 7
# win/initial_setup.ps1
#
# Windows equivalent of initial_setup.sh.
# Run from PowerShell 7 (pwsh) as your normal user — no elevation needed
# except where winget prompts for it internally.
#
# Adjust the two variables below if your WSL distro name or Linux username
# differ from the defaults.

param(
    [string]$WslDistro     = "Ubuntu",
    [string]$WslUser       = $env:USERNAME,
    [string]$PythonVersion = "3.13.2"
)

$DotfilesRoot = "\\wsl$\$WslDistro\home\$WslUser\code\dotfiles"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Step { param([string]$msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Info { param([string]$msg) Write-Host "    $msg" -ForegroundColor Gray }
function Warn { param([string]$msg) Write-Host "    [WARN] $msg" -ForegroundColor Yellow }

function Install-WingetPkg {
    param([string]$Id, [string]$Label = $Id)
    $check = winget list --id $Id --exact 2>$null | Select-String $Id
    if ($check) {
        Info "$Label already installed — skipping."
    } else {
        winget install --id $Id --exact --accept-package-agreements --accept-source-agreements
    }
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ---------------------------------------------------------------------------
# 0. Sanity check: confirm WSL dotfiles are reachable
# ---------------------------------------------------------------------------
if (-not (Test-Path $DotfilesRoot)) {
    Write-Error "Cannot reach dotfiles at '$DotfilesRoot'. Check -WslDistro and -WslUser params."
    exit 1
}

# ---------------------------------------------------------------------------
# 1. Directory structure
# ---------------------------------------------------------------------------
Step "Creating directory structure"
foreach ($d in @("bin","code","data","scrap","venvs","work")) {
    $path = "$HOME\$d"
    if (-not (Test-Path $path)) { New-Item -ItemType Directory $path | Out-Null; Info "Created $path" }
    else                        { Info "$path already exists" }
}

# ---------------------------------------------------------------------------
# 2. Install tools via winget
# ---------------------------------------------------------------------------
Step "Installing tools via winget"
Install-WingetPkg "Git.Git"                  "git"
Install-WingetPkg "Starship.Starship"        "starship"
Install-WingetPkg "Neovim.Neovim"            "neovim"
Install-WingetPkg "junegunn.fzf"             "fzf"
Install-WingetPkg "BurntSushi.ripgrep.MSVC"  "ripgrep"
Install-WingetPkg "sharkdp.fd"               "fd"
Install-WingetPkg "sharkdp.bat"              "bat"
Install-WingetPkg "astral-sh.uv"             "uv"
Install-WingetPkg "JasperDevs.Yoink"         "yoink"
Install-WingetPkg "jqlang.jq"                "jq"

Refresh-Path

# Netskope (and other corporate SSL inspection tools) intercept TLS using a
# CA cert that is trusted by Windows but not by uv's bundled rustls. Setting
# UV_NATIVE_TLS forces uv to use the Windows cert store for all downloads.
$env:UV_NATIVE_TLS = "1"

# ---------------------------------------------------------------------------
# 3. PSFzf PowerShell module
# ---------------------------------------------------------------------------
Step "Installing PSFzf module"
if (Get-Module -ListAvailable -Name PSFzf) {
    Info "PSFzf already installed — skipping."
} else {
    Install-Module -Name PSFzf -Scope CurrentUser -Force
}

# ---------------------------------------------------------------------------
# 4. Copy dotfiles
# ---------------------------------------------------------------------------
Step "Copying dotfiles from WSL"

# starship.toml
$starshipDir = "$HOME\.config"
New-Item -ItemType Directory -Force $starshipDir | Out-Null
Copy-Item "$DotfilesRoot\.config\starship.toml" "$starshipDir\starship.toml" -Force
Info "starship.toml  ->  $starshipDir\starship.toml"

# neovim config
$nvimDest = "$env:LOCALAPPDATA\nvim"
New-Item -ItemType Directory -Force $nvimDest | Out-Null
Copy-Item "$DotfilesRoot\.config\nvim\*" $nvimDest -Recurse -Force
Info "nvim config    ->  $nvimDest"

# git — note: .gitconfig.personal has a Linux SSH key path; update core.sshCommand
# manually if you want native Windows SSH keys instead of WSL ones.
Copy-Item "$DotfilesRoot\.gitconfig"          "$HOME\.gitconfig"          -Force
Copy-Item "$DotfilesRoot\.gitconfig.personal" "$HOME\.gitconfig.personal" -Force
Info ".gitconfig     ->  $HOME\.gitconfig"

# ---------------------------------------------------------------------------
# 5. Python via uv
# ---------------------------------------------------------------------------
Step "Installing Python $PythonVersion via uv"
uv python install $PythonVersion

Step "Creating venv at $HOME\venvs\misc"
if (-not (Test-Path "$HOME\venvs\misc")) {
    uv venv "$HOME\venvs\misc" --python $PythonVersion
} else {
    Info "venv already exists — skipping creation."
}

Step "Installing requirements.txt into venvs\misc"
$req = "$DotfilesRoot\requirements.txt"
if (Test-Path $req) {
    & "$HOME\venvs\misc\Scripts\pip.exe" install -r $req
    Info "requirements installed."
} else {
    Warn "requirements.txt not found at $req — skipping."
}

# ---------------------------------------------------------------------------
# 6. PowerShell profile
# ---------------------------------------------------------------------------
Step "Writing PowerShell profile -> $PROFILE"

if (Test-Path $PROFILE) {
    $backup = "$PROFILE.bak"
    Copy-Item $PROFILE $backup -Force
    Warn "Existing profile backed up to $backup"
}

New-Item -ItemType Directory -Force (Split-Path $PROFILE) | Out-Null

@'
# ---------------------------------------------------------------
# PowerShell profile  (equivalent of .bashrc)
# Generated by win/initial_setup.ps1
# ---------------------------------------------------------------

# Prompt
Invoke-Expression (&starship init powershell)

# FZF key bindings (Ctrl+T: file picker, Ctrl+R: history)
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# Environment
$env:EDITOR = 'nvim'
$env:TZ     = 'Asia/Kolkata'

# Editor aliases
Set-Alias vi  nvim
Set-Alias vim nvim
Set-Alias e   nvim

# Common tool aliases
Set-Alias k   kubectl

# Navigation
function ..  { Set-Location .. }
function ... { Set-Location ..\.. }

# fzf-find-edit: fuzzy find a file and open in nvim  (equivalent of ffe)
function ffe {
    $file = fd --type f | fzf --preview 'bat --color=always {}'
    if ($file) { nvim $file }
}

# fzf-cd: fuzzy cd into a subdirectory  (equivalent of cdf)
function fcd {
    $dir = fd --type d | fzf
    if ($dir) { Set-Location $dir }
}

# Activate misc venv
function workon {
    & "$HOME\venvs\misc\Scripts\Activate.ps1"
}

# Git shortcuts  (mirrors .bashrc spirit)
function gst  { git status -sb @args }
function glog { git log --oneline --graph --decorate -15 @args }

'@ | Set-Content -Path $PROFILE -Encoding UTF8

Info "Profile written."

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host "`nDone." -ForegroundColor Green
Write-Host "Restart your terminal (or run: . `$PROFILE) to activate the new setup."
Write-Host "First nvim launch will install plugins via lazy.nvim."
Write-Host ""
Write-Host "Manual step: if you want native Windows SSH keys instead of WSL ones,"
Write-Host "update 'core.sshCommand' in $HOME\.gitconfig.personal"

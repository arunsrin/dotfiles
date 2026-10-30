# win/initial_setup.ps1
#
# Automated Windows setup script for modern CLI tooling.
# Equivalent of initial_setup.sh for Windows.
#
# Can be run from either Windows PowerShell 5.1 or PowerShell 7 (pwsh).
# Run as your normal user — no elevation required except where winget
# prompts for it internally.

param(
    [string]$WslDistro     = "Ubuntu",
    [string]$WslUser       = $env:USERNAME,
    [string]$PythonVersion = "3.13"
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Step    { param([string]$msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Info    { param([string]$msg) Write-Host "    $msg" -ForegroundColor Gray }
function Warn    { param([string]$msg) Write-Host "    [WARN] $msg" -ForegroundColor Yellow }
function Success { param([string]$msg) Write-Host "    [OK] $msg" -ForegroundColor Green }

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
    
    $userBins = @(
        "$HOME\bin\PowerShell\7",
        "$HOME\bin",
        "$HOME\.local\bin",
        "$HOME\AppData\Local\Microsoft\WinGet\Links"
    )
    foreach ($bin in $userBins) {
        if ((Test-Path $bin) -and ($env:Path -notlike "*$bin*")) {
            $env:Path = "$bin;$env:Path"
        }
    }
}

function Install-WingetPkg {
    param([string]$Id, [string]$Label = $Id)
    $check = winget list --id $Id --exact 2>$null | Select-String $Id
    if ($check) {
        Info "$Label already installed — skipping."
    } else {
        Info "Installing $Label ($Id)..."
        winget install --id $Id --exact --accept-package-agreements --accept-source-agreements
    }
}

# ---------------------------------------------------------------------------
# 0. Locate dotfiles root
# ---------------------------------------------------------------------------
Step "Locating dotfiles root"
$ScriptRepoRoot = (Resolve-Path "$PSScriptRoot\..").Path

if (Test-Path "$ScriptRepoRoot\.gitconfig") {
    $DotfilesRoot = $ScriptRepoRoot
    Success "Found dotfiles locally at $DotfilesRoot"
} elseif (Test-Path "\\wsl$\$WslDistro\home\$WslUser\code\dotfiles") {
    $DotfilesRoot = "\\wsl$\$WslDistro\home\$WslUser\code\dotfiles"
    Success "Found dotfiles in WSL at $DotfilesRoot"
} elseif (Test-Path "$HOME\code\dotfiles") {
    $DotfilesRoot = "$HOME\code\dotfiles"
    Success "Found dotfiles at $DotfilesRoot"
} else {
    Write-Error "Cannot reach dotfiles. Checked local repo, WSL, and $HOME\code\dotfiles."
    exit 1
}

# ---------------------------------------------------------------------------
# 1. Directory structure
# ---------------------------------------------------------------------------
Step "Creating directory structure"
foreach ($d in @("bin", "code", "data", "scrap", "venvs", "work")) {
    $path = "$HOME\$d"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Force $path | Out-Null
        Info "Created $path"
    } else {
        Info "$path already exists"
    }
}

# ---------------------------------------------------------------------------
# 2. Bootstrap PowerShell 7 (if needed)
# ---------------------------------------------------------------------------
Step "Checking PowerShell 7"
Refresh-Path
$pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue

if (-not $pwshCmd) {
    Info "PowerShell 7 not found on PATH. Attempting winget installation..."
    winget install --id Microsoft.PowerShell --exact --accept-package-agreements --accept-source-agreements
    Refresh-Path
    $pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
}

if (-not $pwshCmd) {
    # Fallback to portable zip if winget MSIX install timed out or failed
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $pwshTarget = "$HOME\bin\PowerShell\7"
    if (-not (Test-Path "$pwshTarget\pwsh.exe")) {
        Info "Installing portable PowerShell 7 ($arch) to $pwshTarget..."
        $zipUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.6.9/PowerShell-7.6.9-win-$arch.zip"
        $zipDest = "$env:TEMP\PowerShell-7.6.9.zip"
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipDest -UseBasicParsing
        New-Item -ItemType Directory -Force $pwshTarget | Out-Null
        Expand-Archive -Path $zipDest -DestinationPath $pwshTarget -Force
        Remove-Item -Force $zipDest -ErrorAction SilentlyContinue
    }
    
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$pwshTarget*") {
        [Environment]::SetEnvironmentVariable("Path", "$pwshTarget;$userPath", "User")
    }
    Refresh-Path
    Success "PowerShell 7 portable installed at $pwshTarget"
} else {
    Success "PowerShell 7 is available at $($pwshCmd.Source)"
}

# ---------------------------------------------------------------------------
# 3. Install CLI tools via winget
# ---------------------------------------------------------------------------
Step "Installing CLI tools via winget"

$tools = @(
    @{ Id = "Git.Git"; Label = "git" },
    @{ Id = "Starship.Starship"; Label = "starship" },
    @{ Id = "Neovim.Neovim"; Label = "neovim" },
    @{ Id = "junegunn.fzf"; Label = "fzf" },
    @{ Id = "BurntSushi.ripgrep.MSVC"; Label = "ripgrep" },
    @{ Id = "sharkdp.fd"; Label = "fd" },
    @{ Id = "sharkdp.bat"; Label = "bat" },
    @{ Id = "ajeetdsouza.zoxide"; Label = "zoxide" },
    @{ Id = "eza-community.eza"; Label = "eza" },
    @{ Id = "dandavison.delta"; Label = "delta" },
    @{ Id = "JesseDuffield.lazygit"; Label = "lazygit" },
    @{ Id = "jdx.mise"; Label = "mise" },
    @{ Id = "astral-sh.uv"; Label = "uv" },
    @{ Id = "Derailed.k9s"; Label = "k9s" },
    @{ Id = "bootandy.dust"; Label = "dust" },
    @{ Id = "aristocratos.btop4win"; Label = "btop" },
    @{ Id = "charmbracelet.glow"; Label = "glow" },
    @{ Id = "jqlang.jq"; Label = "jq" }
)

foreach ($t in $tools) {
    Install-WingetPkg $t.Id $t.Label
}

Refresh-Path

# ---------------------------------------------------------------------------
# 4. Install PowerShell Modules
# ---------------------------------------------------------------------------
Step "Installing PowerShell modules"

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue

$modules = @("PSReadLine", "PSFzf", "posh-git", "Terminal-Icons")
foreach ($m in $modules) {
    if (Get-Module -ListAvailable -Name $m) {
        Info "$m already installed — skipping."
    } else {
        Info "Installing module $m..."
        Install-Module -Name $m -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
# 5. Copy dotfiles & configurations
# ---------------------------------------------------------------------------
Step "Copying dotfiles & configuring tools"

# starship.toml
$starshipDir = "$HOME\.config"
New-Item -ItemType Directory -Force $starshipDir | Out-Null
if (Test-Path "$DotfilesRoot\.config\starship.toml") {
    Copy-Item "$DotfilesRoot\.config\starship.toml" "$starshipDir\starship.toml" -Force
    Info "starship.toml  ->  $starshipDir\starship.toml"
}

# neovim config
$nvimDest = "$env:LOCALAPPDATA\nvim"
New-Item -ItemType Directory -Force $nvimDest | Out-Null
if (Test-Path "$DotfilesRoot\.config\nvim") {
    Copy-Item "$DotfilesRoot\.config\nvim\*" $nvimDest -Recurse -Force
    Info "nvim config    ->  $nvimDest"
}

# git configs
if (Test-Path "$DotfilesRoot\.gitconfig") {
    Copy-Item "$DotfilesRoot\.gitconfig" "$HOME\.gitconfig" -Force
    Info ".gitconfig     ->  $HOME\.gitconfig"
}
if (Test-Path "$DotfilesRoot\.gitconfig.personal") {
    Copy-Item "$DotfilesRoot\.gitconfig.personal" "$HOME\.gitconfig.personal" -Force
    Info ".gitconfig.personal -> $HOME\.gitconfig.personal"
}

# Configure delta as git pager
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate "true"
git config --global delta.side-by-side "true"
git config --global delta.line-numbers "true"
Info "Configured git to use delta for side-by-side diffs."

# ---------------------------------------------------------------------------
# 6. Python via uv
# ---------------------------------------------------------------------------
Step "Setting up Python via uv"

$env:UV_SYSTEM_CERTS = "1"
$env:UV_NATIVE_TLS   = "1"

if (Get-Command uv -ErrorAction SilentlyContinue) {
    Info "Installing Python $PythonVersion via uv..."
    uv python install $PythonVersion

    if (-not (Test-Path "$HOME\venvs\misc")) {
        Info "Creating venv at $HOME\venvs\misc..."
        uv venv "$HOME\venvs\misc" --python $PythonVersion
    } else {
        Info "venv at $HOME\venvs\misc already exists — skipping."
    }

    $req = "$DotfilesRoot\requirements.txt"
    if (Test-Path $req) {
        Info "Installing requirements into misc venv via uv..."
        uv pip install -r $req --python "$HOME\venvs\misc"
        Success "requirements.txt installed."
    }
} else {
    Warn "uv not found on PATH yet. Skipping Python venv bootstrap."
}

# Configure mise to ignore linux-only asdf plugins (like hey) in .tool-versions
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise settings set legacy_version_file_disable_tools hey | Out-Null
    mise settings set disable_tools hey | Out-Null
}

# ---------------------------------------------------------------------------
# 7. Install PowerShell Profile
# ---------------------------------------------------------------------------
Step "Installing unified PowerShell profile"

$sourceProfile = "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path $sourceProfile)) {
    $sourceProfile = "$DotfilesRoot\win\Microsoft.PowerShell_profile.ps1"
}

if (Test-Path $sourceProfile) {
    $profileTargets = @(
        "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
        "$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
        "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
        "$HOME\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    )

    if ($PROFILE -and ($profileTargets -notcontains $PROFILE)) {
        $profileTargets += $PROFILE
    }

    foreach ($target in $profileTargets) {
        $parent = Split-Path $target
        if (Test-Path (Split-Path $parent)) {
            if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force $parent | Out-Null }
            if (Test-Path $target) {
                Copy-Item $target "$target.bak" -Force
            }
            Copy-Item $sourceProfile $target -Force
            Info "Profile -> $target"
        }
    }
    Success "PowerShell profiles updated."
} else {
    Warn "Could not find Microsoft.PowerShell_profile.ps1 at $sourceProfile."
}

# ---------------------------------------------------------------------------
# 8. Configure Windows Terminal Profile
# ---------------------------------------------------------------------------
Step "Checking Windows Terminal configuration"

$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    try {
        $wtContent = Get-Content $wtSettings -Raw | ConvertFrom-Json
        $pwshGuid = "{574e775e-4f2a-5b96-ac1e-a2962a402336}"
        $existing = $wtContent.profiles.list | Where-Object { $_.guid -eq $pwshGuid -or $_.name -eq "PowerShell 7" }

        if (-not $existing) {
            $pwshExe = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
            if (-not $pwshExe) { $pwshExe = "$HOME\bin\PowerShell\7\pwsh.exe" }

            $newProfile = [PSCustomObject]@{
                guid              = $pwshGuid
                name              = "PowerShell 7"
                commandline       = $pwshExe
                fontFace          = "FiraCode Nerd Font"
                fontSize          = 11
                startingDirectory = "%USERPROFILE%"
                hidden            = $false
            }
            $wtContent.profiles.list = @($newProfile) + @($wtContent.profiles.list)
            $wtContent | ConvertTo-Json -Depth 20 | Set-Content $wtSettings -Encoding UTF8
            Success "Added PowerShell 7 profile to Windows Terminal."
        } else {
            Info "Windows Terminal already has a PowerShell 7 profile."
        }
    } catch {
        Warn "Could not update Windows Terminal settings: $_"
    }
} else {
    Info "Windows Terminal settings not found at default location — skipping."
}

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "1. Launch Windows Terminal and select the 'PowerShell 7' profile."
Write-Host "2. Read win/README.md for keybindings, aliases, and tool reference."
Write-Host "3. First nvim launch will automatically install plugins via lazy.nvim."
Write-Host "4. If using native Windows SSH keys, ensure core.sshCommand is set in ~/.gitconfig.personal.`n"

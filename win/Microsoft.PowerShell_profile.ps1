# =============================================================================
# PowerShell Profile (~/.bashrc equivalent for Windows)
# =============================================================================

# 1. Environment & Paths
# Refresh PATH from registry so winget packages and user bins are always available
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

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

$env:EDITOR = "nvim"
$env:VISUAL = "nvim"
$env:TZ     = "Asia/Kolkata"
$env:UV_SYSTEM_CERTS = "1"
$env:UV_NATIVE_TLS   = "1"

# 2. Starship Prompt (Uses ~/.config/starship.toml)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# 3. Zoxide (Smart directory jumping with z and zi)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# 4. PSReadLine: Predictive IntelliSense & Emacs Keybindings
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    try {
        # Set Emacs editing mode (Ctrl+A, Ctrl+E, Ctrl+K, Ctrl+W, etc.)
        Set-PSReadLineOption -EditMode Emacs
        
        # Predictive IntelliSense (PowerShell 7+)
        if ($PSVersionTable.PSVersion.Major -ge 7 -and -not [Console]::IsOutputRedirected) {
            Set-PSReadLineOption -PredictionSource HistoryAndPlugin
            Set-PSReadLineOption -PredictionViewStyle ListView
        }
        
        # Tab completion menu
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        
        # F2 toggles between ListView and InlineView
        Set-PSReadLineKeyHandler -Key F2 -ScriptBlock {
            param($key, $arg)
            $style = (Get-PSReadLineOption).PredictionViewStyle
            if ($style -eq 'ListView') {
                Set-PSReadLineOption -PredictionViewStyle InlineView
            } else {
                Set-PSReadLineOption -PredictionViewStyle ListView
            }
        }
    } catch {}
}

# 5. Fuzzy Finding with PSFzf
if (Get-Module -ListAvailable -Name PSFzf) {
    try {
        Import-Module PSFzf -ErrorAction SilentlyContinue
        if (Get-Command fzf -ErrorAction SilentlyContinue) {
            Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
        }
    } catch {}
}

# 6. Git Prompt & Autocompletion
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git -ErrorAction SilentlyContinue
}

# 7. Terminal Icons (Nerd Font icons in Get-ChildItem)
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# 8. Mise (asdf alternative reading .tool-versions)
if ($PSVersionTable.PSVersion.Major -ge 7 -and (Get-Command mise -ErrorAction SilentlyContinue)) {
    Invoke-Expression (&mise activate pwsh | Out-String)
}

# =============================================================================
# Aliases & Functions (Ported from ~/.bashrc)
# =============================================================================

# Editor aliases
Set-Alias vi   nvim -Option AllScope -Force -ErrorAction SilentlyContinue
Set-Alias vim  nvim -Option AllScope -Force -ErrorAction SilentlyContinue
Set-Alias e    nvim -Option AllScope -Force -ErrorAction SilentlyContinue

# DevOps & Tools aliases
Set-Alias k    kubectl  -Option AllScope -Force -ErrorAction SilentlyContinue
Set-Alias lg   lazygit  -Option AllScope -Force -ErrorAction SilentlyContinue
Set-Alias btop btop4win -Option AllScope -Force -ErrorAction SilentlyContinue

# Modern file listings with eza (if installed) or fallback
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function l    { eza --icons $args }
    function la   { eza --icons -a $args }
    function ll   { eza --icons -la $args }
    function lr   { eza --icons -l --sort=modified $args }
    function sl   { eza --icons $args }
    function tree { eza --icons --tree $args }
} else {
    function l    { Get-ChildItem $args }
    function la   { Get-ChildItem -Force $args }
    function ll   { Get-ChildItem -Force $args }
}

# Paging with bat (p in .bashrc)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function p { bat $args }
}

# Directory navigation (matching .., ... in .bashrc)
function ..  { Set-Location .. }
function ... { Set-Location ..\.. }
function pd  { Push-Location $args }
function pd2 { Push-Location +2 $args }
function pd3 { Push-Location +3 $args }
function po  { Pop-Location }

# Fuzzy Find & Edit into nvim (ffe in .bashrc)
function ffe {
    $file = fd --type f | fzf --preview 'bat --color=always {}'
    if ($file) { nvim $file }
}

# Fuzzy cd (cdf in .bashrc)
function fcd {
    $dir = fd --type d | fzf
    if ($dir) { Set-Location $dir }
}

# Quick ping (p8 in .bashrc)
function p8 { ping 8.8.8.8 }

# Git shortcuts (wat and st in .bashrc)
function gst  { git status -sb $args }
function glog { git log --graph --decorate --oneline -15 $args }

# Side-by-side diff using delta (mydiff in .bashrc)
function mydiff {
    param([Parameter(Mandatory=$true)][string]$File1, [Parameter(Mandatory=$true)][string]$File2)
    delta --side-by-side $File1 $File2
}

# TLS Certificate Inspection (mygetcert in .bashrc)
function mygetcert {
    param([Parameter(Mandatory=$true)][string]$HostName, [int]$Port = 443)
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient($HostName, $Port)
        $ssl = New-Object System.Net.Security.SslStream($tcp.GetStream(), $false, { $true })
        $ssl.AuthenticateAsClient($HostName)
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($ssl.RemoteCertificate)
        $cert | Format-List Subject, Issuer, NotBefore, NotAfter, Thumbprint
        $tcp.Close()
    } catch {
        Write-Error "Failed to retrieve certificate from ${HostName}:${Port}: $_"
    }
}

# Activate Python Virtual Environment (workon in .bashrc)
function workon {
    param([string]$Name = "misc")
    $activate = "$HOME\venvs\$Name\Scripts\Activate.ps1"
    if (Test-Path $activate) {
        & $activate
    } else {
        Write-Warning "Virtualenv '$Name' not found at $activate."
    }
}



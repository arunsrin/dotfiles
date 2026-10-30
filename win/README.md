# Windows & PowerShell Modern CLI Setup Guide

This guide documents the modern CLI toolchain configured for your Windows environment. It is designed to match and exceed the capabilities of your Linux dotfiles ([`.bashrc`](../.bashrc), [`.tool-versions`](../.tool-versions), and [`.config/starship.toml`](../.config/starship.toml)), giving you a rich, keyboard-driven terminal workflow.

---

## Quick Start on a New Laptop

To replicate this exact setup on another Windows machine (ARM64 or x64):

1. Clone your dotfiles repository:
   ```powershell
   git clone git@github.com:arunsrin/dotfiles.git $HOME\code\dotfiles
   cd $HOME\code\dotfiles
   ```
2. Run the automated setup script (works from standard Windows PowerShell 5.1 or PowerShell 7):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\win\initial_setup.ps1
   ```
3. Restart Windows Terminal and select **PowerShell 7**.

---

## Architecture & Directory Layout

- **Shell Engine**: PowerShell 7 (`pwsh.exe`) in `~/bin/PowerShell/7` or system PATH.
- **Profiles**:
  - PowerShell 7 Profile: `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` (or OneDrive equivalent)
  - Windows PowerShell Profile: `~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`
  - Tracked in Dotfiles: `win/Microsoft.PowerShell_profile.ps1`
- **Config Files**:
  - Starship: `~/.config/starship.toml`
  - Neovim: `~/AppData/Local/nvim`
  - Terminal Settings: Windows Terminal with `FiraCode Nerd Font` and `PowerShell 7` profile.
- **Python Virtualenvs**: `~/venvs/misc` (Python 3.13 via `uv`).

---

## Quick Reference: Keybindings

| Chord | Context | Action |
| :--- | :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> | PSFzf | Fuzzy find files in current directory with `bat` syntax preview |
| <kbd>Ctrl</kbd> + <kbd>R</kbd> | PSFzf | Fuzzy reverse search through command history |
| <kbd>Alt</kbd> + <kbd>C</kbd> | PSFzf | Fuzzy find directory and `cd` into it |
| <kbd>Tab</kbd> | PSReadLine | Open interactive tab-completion menu (arrow keys to navigate) |
| <kbd>F2</kbd> | PSReadLine | Toggle prediction display style (`ListView` ↔ `InlineView`) |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> | PSReadLine | Jump to beginning of line (Emacs edit mode) |
| <kbd>Ctrl</kbd> + <kbd>E</kbd> | PSReadLine | Jump to end of line (Emacs edit mode) |
| <kbd>Ctrl</kbd> + <kbd>K</kbd> | PSReadLine | Kill (cut) from cursor to end of line |
| <kbd>Ctrl</kbd> + <kbd>U</kbd> | PSReadLine | Kill (cut) from cursor to start of line |
| <kbd>Ctrl</kbd> + <kbd>W</kbd> | PSReadLine | Delete previous word |
| <kbd>Ctrl</kbd> + <kbd>Y</kbd> | PSReadLine | Yank (paste) previously killed text |

---

## Tool-by-Tool Guide

### 1. `pwsh` (PowerShell 7) & `PSReadLine`
- **What it is**: Modern cross-platform shell built on .NET 8/9 with predictive IntelliSense, syntax highlighting, and Emacs keybindings.
- **Prediction Modes**:
  - As you type, previous history matches appear in a floating list below your prompt.
  - Press <kbd>Down Arrow</kbd> to enter the suggestion list, or <kbd>Right Arrow</kbd> to accept inline predictions.
  - Press <kbd>F2</kbd> to switch between `ListView` and `InlineView`.

---

### 2. `zoxide` (`z`) — Smart Directory Navigation
- **What it is**: Learns your navigation habits and jumps to frequent/recent directories using partial matching. Replaces manual `cd` and `pushd`.
- **Common Usage**:
  ```powershell
  z dot           # Jumps directly to C:\Users\gnuar\code\dotfiles
  z code          # Jumps to C:\Users\gnuar\code
  z ..            # Jumps up one directory
  zi              # Opens interactive fzf selection menu of your top directories
  ```

---

### 3. `fzf` & `PSFzf` — Interactive Fuzzy Finding
- **What it is**: Command-line fuzzy finder with full PowerShell integration and `bat` syntax previewing.
- **Custom Functions Ported from `.bashrc`**:
  ```powershell
  ffe             # Fuzzy Find & Edit: searches files, previews them with bat, opens in nvim
  fcd             # Fuzzy CD: searches subdirectories and immediately navigates into the chosen one
  ```
- **CLI Commands**:
  ```powershell
  fzf                             # Interactive fuzzy file selector
  git branch | fzf                # Pipe any command output into fuzzy search
  Get-Process | fzf               # Search running processes interactively
  ```

---

### 4. `eza` — Modern `ls` with Icons & Git Status
- **What it is**: Fast, colorized replacement for `ls` / `dir` with Nerd Font file icons and git repository status.
- **Configured Aliases**:
  ```powershell
  l               # eza --icons (compact grid)
  la              # eza --icons -a (include hidden files)
  ll              # eza --icons -la (full detailed listing)
  lr              # eza --icons -l --sort=modified (sorted by modification time, newest last)
  tree            # eza --icons --tree (hierarchical visual tree of directory)
  ```
- **Useful Flags**:
  ```powershell
  eza --git -l                     # Shows staged/unstaged git status per file
  eza --tree --level=2             # Limit tree depth to 2 levels
  ```

---

### 5. `bat` — Syntax-Highlighted Cat & Pager
- **What it is**: Enhanced `cat` / `less` with syntax highlighting, line numbering, and Git change gutter indicators.
- **Configured Alias**:
  ```powershell
  p <file>        # Aliased to bat (matches `p` in .bashrc)
  ```
- **Common Usage**:
  ```powershell
  bat main.py                      # View file with line numbers and syntax colors
  bat -n file.txt                  # Force line numbers
  bat --diff file.py               # View only Git changes within the file
  git show HEAD:file.py | bat -l py # Pipe output and specify language syntax
  ```

---

### 6. `delta` — Side-by-Side Diffs
- **What it is**: Git pager and standalone syntax-highlighting diff viewer. Automatically configured as your global `git diff` pager.
- **Custom Function**:
  ```powershell
  mydiff file1.txt file2.txt       # Side-by-side terminal diff (replaces .bashrc mydiff)
  ```
- **Git Integration**:
  ```powershell
  git diff                         # Automatically displays via delta with side-by-side layout
  git log -p                       # Commits and patches rendered with syntax highlighting
  ```

---

### 7. `lazygit` (`lg`) — Terminal UI for Git
- **What it is**: High-speed, keyboard-centric terminal UI for Git. Replaces `tig`.
- **Configured Alias**:
  ```powershell
  lg                               # Launch lazygit in current repo
  ```
- **Key Navigation in Lazygit**:
  - `1`, `2`, `3`, `4`, `5`: Jump between Status, Files, Branches, Commits, and Stash panels.
  - `Space`: Stage/unstage file or selected lines.
  - `c`: Commit staged changes.
  - `P`: Push to remote.
  - `p`: Pull from remote.
  - `b`: Open branches view / checkout branch.
  - `?`: Toggle keybindings cheat sheet.

---

### 8. `mise` — Multi-Runtime Version Manager (asdf Replacement)
- **What it is**: Blazing-fast Rust-based tool version manager that **natively reads your `.tool-versions` file**.
- **Common Usage**:
  ```powershell
  mise install                     # Installs all tools declared in .tool-versions
  mise current                     # Shows currently active tool versions
  mise ls                          # Lists all installed runtimes
  mise use node@20                 # Set tool version for current directory
  mise run <task>                  # Run mise tasks
  ```

---

### 9. `uv` — Python Package & Virtualenv Manager
- **What it is**: Ultra-fast Python package and project manager written in Rust.
- **Common Usage**:
  ```powershell
  workon                           # Activates ~/venvs/misc (matches .bashrc)
  workon myproject                 # Activates ~/venvs/myproject
  uv python install 3.12           # Download and install any Python version
  uv venv myenv --python 3.12      # Create a new virtualenv
  uv pip install <pkg>             # Blazing fast pip installer
  uvx ruff check .                 # Run any PyPI tool ephemerally without installing
  ```

---

### 10. `k9s` — Kubernetes Cluster Dashboard
- **What it is**: Full terminal UI for managing Kubernetes pods, logs, deployments, and contexts.
- **Common Usage**:
  ```powershell
  k9s                              # Launch cluster dashboard
  k9s --context dev                # Open directly into a specific cluster context
  k9s -n kube-system               # Open filtered to a specific namespace
  ```
- **Key Shortcuts inside K9s**:
  - `:pods`, `:svc`, `:deploy`: Jump directly to resource views.
  - `l`: Tail logs of focused pod/container.
  - `d`: Describe resource.
  - `e`: Edit manifest in `$EDITOR` (`nvim`).
  - `s`: Shell into running container.

---

### 11. `dust` — Disk Usage Visualizer (ncdu Replacement)
- **What it is**: Instant, graphical terminal disk usage analysis showing horizontal bar graphs.
- **Common Usage**:
  ```powershell
  dust                             # Analyze current directory
  dust -d 2                        # Limit depth to 2 levels
  dust -p                          # Full paths
  dust C:\Users\gnuar\code         # Analyze specific target folder
  ```

---

### 12. `btop` — System Resource Monitor (glances Replacement)
- **What it is**: Real-time terminal hardware monitor displaying CPU cores, memory, disks, network activity, and process tree.
- **Configured Alias**:
  ```powershell
  btop                             # Launches btop4win
  ```
- **Key Shortcuts inside Btop**:
  - `m`: Toggle memory panel.
  - `p`: Toggle process panel.
  - `n`: Toggle network panel.
  - `e`: Toggle process tree view.
  - `q`: Quit.

---

### 13. `glow` — Terminal Markdown Reader
- **What it is**: Beautiful GitHub-accurate Markdown renderer in the CLI.
- **Common Usage**:
  ```powershell
  glow README.md                   # Render file with colors, tables, and formatting
  glow -p README.md                # Render with pager (scrollable)
  glow https://github.com/org/repo # Render directly from a GitHub URL
  ```

---

### 14. `fd` & `rg` (ripgrep) — Fast Search
- **`fd`** (Find files):
  ```powershell
  fd app                           # Find files/folders matching 'app'
  fd -e ps1                        # Find only files ending in .ps1
  fd -t d                          # Find only directories
  fd -H secret                     # Search including hidden files
  ```
- **`rg`** (Search text content):
  ```powershell
  rg "function"                    # Search current directory recursively
  rg -t py "import requests"       # Search only inside Python files
  rg -i "pattern"                  # Case-insensitive search
  rg --files                       # List all tracked files (respects .gitignore)
  ```

---

## Custom Ported `.bashrc` Functions

| Function | Equivalent in Linux | Action |
| :--- | :--- | :--- |
| `vi <file>`, `vim <file>`, `e <file>` | `vim` / `emacs` | Opens file in Neovim |
| `k <args>` | `kubectl` | Shortcut for `kubectl` |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `pd <dir>`, `po` | `pushd`, `popd` | Directory stack navigation |
| `pd2`, `pd3` | `pushd +2`, `+3` | Jump directly into stack offsets |
| `p8` | `ping 8.8.8.8` | Quick network latency check |
| `p <file>` | `less` | View file via `bat` |
| `ffe` | `fzf_find_edit` | Fuzzy find file with preview and open in `nvim` |
| `fcd` | `cdf` | Fuzzy search directory and navigate into it |
| `gst` | `git status -sb` | Concise branch and file git status |
| `glog` | `wat` | Compact decorated git commit graph |
| `mydiff <a> <b>` | `diff --side-by-side` | Syntax-highlighted side-by-side file diff via `delta` |
| `mygetcert <host> [port]` | `openssl s_client` | TLS cert inspection via .NET `SslStream` (Subject, Issuer, Expiry) |
| `workon [name]` | `source venvs/misc/bin/activate` | Activate Python virtual environment (defaults to `misc`) |

---

## PowerShell-Exclusive Superpowers (No Direct Linux Equivalent)

### 1. `Out-GridView` (`ogv`) — Instant Interactive GUI Table
Because PowerShell passes structured .NET objects rather than plain text streams, you can pipe any output into a searchable, filterable GUI table window:
```powershell
# Interactively search processes and kill selected ones:
Get-Process | Out-GridView -PassThru | Stop-Process

# Select a git branch from a GUI table and check it out:
git branch -a | Out-GridView -PassThru | git checkout

# Inspect all installed winget packages interactively:
winget list | Out-GridView
```

### 2. `Test-NetConnection` (`tnc`) — Advanced Diagnostics
Replaces `ping`, `traceroute`, and `telnet` in a single command:
```powershell
tnc google.com -Port 443         # Tests DNS resolution + TCP port connection
tnc 8.8.8.8 -TraceRoute          # Performs ICMP trace
```

### 3. Native Object Filtering & Formatting
Instead of `awk`, `sed`, and `cut`, filter properties directly on objects:
```powershell
Get-ChildItem -Recurse | Where-Object Length -gt 50MB | Select-Object Name, Length, LastWriteTime
```

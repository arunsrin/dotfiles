# arunsrin/dotfiles

Here are my dotfiles for vim, bash, emacs and a few others.

## Folder structure

- `~/bin` for binaries like kubectl and small shell-scripts
- `~/packages` for larger packages, manually compiled stuff etc
- `~/code` for personal git repos
- `~/work` for work git repos

## Setup

```sh
./initial_setup.sh
```

This script can be run repeatedly and is fairly simple. It:
- installs some ubuntu packages (emacs, fzf, ripgrep, fd, pandoc, etc)
- installs asdf
- installs some asdf packages (python, kubectl etc)
- installs Emacs prerequisites (gopls, pyright, grip — see below)
- copy all the dotfiles over to $HOME

The only manual steps currently are mentioned in the `.vimrc` header, for
vundle setup.

## Emacs

`.emacs.d/init.el` is a modern, `use-package`-based config on stock Emacs 29+
(no Spacemacs/Doom). All Emacs packages self-install from MELPA on first launch.
Highlights:

- **Fuzzy navigation** (Telescope-style): vertico + orderless + marginalia +
  consult. `M-s g` ripgrep, `C-x b` buffers, `C-c f` project files,
  `C-x C-r` recent files, `M-s l` search lines.
- **LSP + completion**: `eglot` (built-in) with corfu/cape popups. Auto-starts
  for Python (pyright) and Go (gopls).
- **Git**: magit (`C-x g`) + diff-hl gutter signs.
- **Tabs**: `tab-bar-mode` (`C-x t n`, `C-<tab>`).
- **Markdown**: markdown-mode + grip-mode (GitHub-accurate live preview,
  `C-c C-c g`) + `markdown-preview-glow` (terminal render via glow).
- **Theme**: Solarized Light.

External prerequisites (installed by `initial_setup.sh`): `gopls`, `pyright`
(via npm), `grip` (via uv), `pandoc`, `ripgrep`, `fd`, `glow`. Tree-sitter
grammars install on demand inside Emacs via
`M-x treesit-install-language-grammar`.

### Emacs as `$EDITOR` (daemon)

`.bashrc` sets `EDITOR="emacsclient -t -a ''"`, so git, claude code,
`crontab -e`, `kubectl edit`, etc. all open in a terminal Emacs frame that
shares buffers/state. The `-a ''` auto-spawns a daemon on first use.

`initial_setup.sh` also enables the systemd user service so the daemon starts
eagerly and survives logout (using the unit shipped by the emacs package):

```sh
systemctl --user enable --now emacs   # no @ or $USER -- it's a plain unit
loginctl enable-linger "$USER"        # keep it alive without an active login
```

On older WSL without `systemd --user`, skip this -- the `-a ''` fallback
spawns the daemon lazily instead. Check the daemon with
`systemctl --user status emacs` or `emacsclient -t -a '' --eval '(emacs-version)'`.

## Notes to self

Periodically run this to update asdf's `.tool-versions` to their latest
equivalents:

```sh
# this shows latest available versions for installed tools:
asdf latest --all
# edit the .tool-versions file with the ones you want to update to, and run this:
asdf update
```

Similarly for python, just run this every once in a while:

```sh
pip-review --auto
```

This will update all installed packages. Freeze and commit the
`requirements.txt`.

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
- installs some ubuntu packages (emacs, fzf, etc)
- installs asdf
- installs some asdf packages (python, kubectl etc)
- copy all the dotfiles over to $HOME

The only manual steps currently are mentioned in the `.vimrc` header, for
vundle setup.

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

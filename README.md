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


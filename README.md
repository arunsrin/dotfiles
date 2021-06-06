# arunsrin/dotfiles

Here are my dotfiles for vim, bash, emacs and a few others.

## Folder structure

- `~/bin` for small binaries
- `~/packages` for larger packages
- `~/code` for personal git repos
- `~/work` for work git repos

## Getting things ready

```sh
sudo apt update
sudo apt upgrade -y
sudo apt install fzf build-essential // more here that I can't remember right now
```

## Setup

On a new dev setup:

- Clone this repo. 
	- I like to keep stuff like this in `~/code` and work stuff in `~/work` so
	that my git commits use my personal and work emails respectively (See
	`.gitconfig` and `.gitconfig.personal` for how that bit works)
- Copy files over (manually)
- Check the `.vimrc` header for a couple of its pre-requisites
- Start emacs, it should just auto-install everything
- `./install/install_starship.sh` to get starship to `~/bin`
- `./install/install_go.sh` to install go to `~/packages`


## TODO

I build my own emacs usually. Steps for Fedora family are [here](https://gist.github.com/harrifeng/a3ebd9a2af4c65cacfd4). Need to come up with similar steps for Ubuntu.

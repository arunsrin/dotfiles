# Good luck running this all in one go. This is just a reference from a new WSL
# instance and may or may not work in all environments.

# some useful packages, always run this
sudo apt update
sudo apt install emacs-nox git fzf jq python3 python-is-python3 virtualenv \
  inetutils-traceroute make tree unzip bat tig gron ncdu tldr \
  python3-dev python3-pip libxml2-dev xonsh libssl-dev libzmq3-dev \
  libsqlite3-dev build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl git \
  xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  exuberant-ctags ripgrep fd-find pandoc

# locale configuration
sudo locale-gen en_US.UTF-8

# Setup my folder structure
mkdir -p ~/{bin,code,data,go,packages,scrap,venvs,work}

# install uv to manage python
export MY_PYTHON_VERSION=3.13.2
curl -LsSf https://astral.sh/uv/install.sh | sh
~/.local/bin/uv python install cpython-${MY_PYTHON_VERSION}-linux-x86_64-gnu
~/.local/bin/uv venv ~/venvs/misc --python ${MY_PYTHON_VERSION}

# install and setup asdf
if [ ! -f ~/bin/asdf ]; then
  # git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.16.0
  cd ~/packages
  curl -LO https://github.com/asdf-vm/asdf/releases/download/v0.16.7/asdf-v0.16.7-linux-arm64.tar.gz
  tar zxvf asdf-v0.16.7-linux-arm64.tar.gz
  chmod +x asdf
  mv asdf ~/bin
fi

# install the rest using asdf.
echo -e "\n Setting up packages using asdf"
cp .tool-versions ~/
# first add the plugins
# ref https://dev.to/deepanchal/setup-asdf-direnv-5afo
cat ~/.tool-versions | awk ' {print $1}' | xargs -I _ asdf plugin add _
# and then install them
asdf install
while read line; do
  asdf set $line
done <~/.tool-versions
asdf reshim

# krew plugins
kubectl krew install ctx ns tail tree

# go
curl -LO https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz

# glow markdown reader (also used by emacs markdown-preview-glow)
go install github.com/charmbracelet/glow@latest

# Emacs prerequisites (LSP servers + markdown preview).
# The modern init.el uses eglot (LSP), corfu (completion), and markdown
# preview; these external tools back them.
echo -e "\n Setting up Emacs prerequisites (LSP servers, markdown preview)"
# gopls: Go language server for eglot
go install golang.org/x/tools/gopls@latest
# pyright: Python language server for eglot (nodejs comes from asdf above)
npm install -g pyright
# grip: GitHub-accurate live markdown preview (grip-mode in emacs)
~/.local/bin/uv tool install grip
# Debian/Ubuntu ships fd-find as `fdfind`; emacs/consult expect `fd`.
# Symlink it onto PATH so project file-finding uses it.
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" ~/bin/fd
fi

# My catch-all virtualenv
if [ ! -d ~/venvs/misc ]; then
  ~/.local/bin/uv venv ~/venvs/misc --python ${MY_PYTHON_VERSION}
  source ~/venvs/misc/bin/activate
  ~/venvs/misc/bin/pip install -r requirements.txt
  deactivate
fi

# pyenv: https://github.com/pyenv/pyenv
curl https://pyenv.run | bash
# usage:
# pyenv update -> update package lists
# pyenv install -l -> list available pythons
# pyenv install 3.12.4 ->download compile and install
# pyenv global 3.12.4 ->use this version for this user
# pyenv shell <version> ->just for current shell session
# pyenv local <version> ->for current dir and subdirs

# neovim setup, https://github.com/AstroNvim/AstroNvim?tab=readme-ov-file
git clone --depth 1 https://github.com/AstroNvim/template $env:LOCALAPPDATA\nvim
rm -rf ~/.config/nvim/.git
# nvim

# copy all the dotfiles over
for i in .bashrc bin .config .ctags .dircolors .emacs.d .fzf .gitconfig .gitconfig.personal initial_setup.sh .kube-ps1.sh .pythonrc.py .screenrc .tmux.conf .vimrc
do
  echo -e "\n Copying $i to $HOME"
  cp -r $i ~/
done

# Emacs daemon: $EDITOR is `emacsclient -t -a ''` (set in .bashrc), so git,
# claude code, crontab -e etc. open in a shared terminal Emacs frame. The
# `-a ''` auto-spawns a daemon on first use, but enabling the systemd user
# service makes startup eager and survives logout. Uses the unit shipped by
# the emacs package (/usr/lib/systemd/user/emacs.service) -- no @ or $USER.
# (Skipped automatically if systemd --user isn't active, e.g. older WSL.)
echo -e "\n Enabling Emacs daemon (systemd --user)"
if systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user enable --now emacs
  loginctl enable-linger "$USER"   # keep daemon alive without an active login
else
  echo " systemd --user not active; skipping. The -a '' in \$EDITOR will"
  echo " auto-spawn a daemon on first use instead."
fi

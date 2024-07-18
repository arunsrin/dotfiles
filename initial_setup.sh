# Good luck running this all in one go. This is just a reference from a new WSL
# instance and may or may not work in all environments.

# some useful packages, always run this
sudo apt update
sudo apt install emacs-nox git fzf ctags jq python3 python-is-python3 virtualenv \
  inetutils-traceroute make tree unzip bat tig gron ncdu tldr \
  python3-dev python3-pip libxml2-dev xonsh libssl-dev libzmq3-dev \
  libsqlite3-dev build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl git \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Setup my folder structure
mkdir -p ~/{bin,code,data,go,packages,scrap,venvs,work}

# install and setup asdf
if [ ! -d ~/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0
  . $HOME/.asdf/asdf.sh
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
  asdf global $line
done <~/.tool-versions

# krew plugins
kubectl krew install ctx ns tail tree

# My catch-all virtualenv
if [ ! -d ~/venvs/misc ]; then
  python3 -m venv ~/venvs/misc
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

# copy all the dotfiles over
for i in .bashrc bin .config .ctags .dircolors .emacs.d .fzf .gitconfig .gitconfig.personal initial_setup.sh .kube-ps1.sh .pythonrc.py .screenrc .tmux.conf .vimrc
do
  echo -e "\n Copying $i to $HOME"
  cp -r $i ~/
done

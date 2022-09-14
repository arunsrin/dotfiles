# Good luck running this all in one go. This is just a reference from a new WSL
# instance and may or may not work in all environments.

# some useful packages, always run this
sudo apt update
sudo apt install emacs-nox git fzf ctags jq python3 python-is-python3 virtualenv \
  inetutils-traceroute make tree unzip bat tig gron ncdu tldr \
  python3-dev python3-pip libxml2-dev xonsh libssl-dev libzmq3-dev \
  libsqlite3-dev

# Setup my folder structure
mkdir -p ~/{bin,code,data,go,packages,scrap,venvs,work}

# install and setup asdf
if [ ! -d ~/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0
  . $HOME/.asdf/asdf.sh
fi

# install the rest using asdf. not sure if this works well repeatably. use with
# caution.
for package in python golang kubectl helm krew github-cli starship hey k9s vim nodejs
do
  echo -e "\nInstalling $package using asdf..\n"
  asdf plugin add $package
  asdf install $package latest
  asdf global $package latest
done

# krew plugins
kubectl krew install ctx ns tail tree

# My catch-all virtualenv
if [ ! -d ~/venvs/misc ]; then
  python3 -m venv ~/venvs/misc
  source ~/venvs/misc/bin/activate
  ~/venvs/misc/bin/pip install -r requirements.txt
  deactivate
fi

# copy all the dotfiles over
for i in .bashrc bin .config .ctags .dircolors .emacs.d .fzf .gitconfig .gitconfig.personal initial_setup.sh .kube-ps1.sh .pythonrc.py .screenrc .tmux.conf .vimrc
do
  echo -e "\n Copying $i to $HOME"
  cp -r $i ~/
done

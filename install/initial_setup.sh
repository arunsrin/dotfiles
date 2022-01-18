# Good luck running this all in one go. This is just a reference from a new WSL
# instance and may or may not work in all environments.


# install software-properties-common..
if grep neovim /etc/apt/sources.list.d/*>/dev/null; then
  echo "neovim repo already present"
else
  sudo apt update && sudo apt install software-properties-common
  # ..so we can add the neovim repo
  sudo add-apt-repository ppa:neovim-ppa/stable
fi

# some useful packages, always run this
sudo apt update
sudo apt install emacs-nox git fzf ctags jq python3 python-is-python3 virtualenv \
  inetutils-traceroute make tree unzip bat tig gron ncdu tldr \
  neovim python3-dev python3-pip

# I always have a ~/bin and ~/packages
mkdir -p ~/bin ~/packages

# kubectl
if [ ! -f ~/bin/k9s ]; then
  cd ~/bin
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
else
  echo "kubectl is present"
fi

# helm
if [ ! -f ~/bin/k9s ]; then
  cd ~/packages
  wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
  mv linux-amd64/helm ~/bin
  chmod +x ~/bin/helm
  rm -rf linux-amd64
else
  echo "helm is present"
fi

# k9s
if [ ! -f ~/bin/k9s ]; then
  wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
  tar zxvf k9s_Linux_x86_64.tar.gz
  chmod +x k9s
  mv k9s ~/bin
  rm LICENSE README.md
else
  echo "k9s is present"
fi

# krew, package manager for kubectl. The blob below is from their quickstart
# my .bashrc already has the settings for loading ~/.krew

if kubectl krew version>/dev/null; then
  echo "krew is present"
else
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )
  # source or open a new window and install these:
  kubectl krew install ctx ns tail tree
fi

# w32yank for neovim
# https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl
if [ ! -f ~/bin/win32yank.exe ]; then
  curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
  unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
  chmod +x /tmp/win32yank.exe
  mv /tmp/win32yank.exe ~/bin
else
  echo "w32yank is present"
fi

# My catch-all virtualenv
if [ ! -d ~/venvs/misc ]; then
  mkdir -p ~/venvs
  python3 -m venv ~/venvs/misc
fi
source ~/venvs/misc/bin/activate
pip install -r requirements.txt
deactivate

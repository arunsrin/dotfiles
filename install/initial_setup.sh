# Good luck running this all in one go. This is just a reference from a new WSL
# instance and may or may not work in all environments.

# some useful packages
sudo apt install emacs-nox git fzf ctags jq python3 python-is-python3 virtualenv \
  inetutils-traceroute make tree unzip

# I always have a ~/bin and ~/packages
mkdir -p ~/bin ~/packages

# kubectl
cd ~/bin
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl

# helm
cd ~/packages
wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
mv linux-amd64/helm ~/bin
chmod +x ~/bin/helm
rm -rf linux-amd64

# k9s
wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
tar zxvf k9s_Linux_arm64.tar.gz
chmod +x k9s
mv k9s ~/bin
rm LICENSE README.md

# krew, package manager for kubectl. The blob below is from their quickstart
# my .bashrc already has the settings for loading ~/.krew

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"${OS}_${ARCH}" &&
  "$KREW" install krew
)

# source or open a new window and install these:
kubectl krew install ctx ns tail tree

# krew: a plugin manager for kubectl

## Download and install it:

```sh
cd ~/packages
wget "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz"
tar zxvf krew.tar.gz
rm LICENSE krew-darwin_a* krew-linux_arm*
rm krew.tar.gz
mv krew-linux_amd64 krew
mv krew ~/bin
krew install krew
```

## Install plugins

Some nice plugins that I tried:

```sh
k krew update
k krew install ctx
k krew install ns
k krew install tail
k krew install tree
```

# .bashrc
# need this to workaround the error: 
# 'stty: standard input: Inappropriate ioctl for device'
[[ $- == *i* ]] && stty -ixon

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
function    k                { kubectl $@; }
function    p                { batcat $@; }
function    et               { emacsclient $@; }
function    e                { emacsclient -c -a emacs $@; }
function    lr               { exa -lr --sort=mod $@; }
function    l                { exa $@; }
function    sl               { exa $@; }
function    ls               { exa $@; }
function    la               { exa -Fa $@; }
function    pd               { pushd $@; }
function    pd2              { pushd +2 $@; }
function    pd3              { pushd +3 $@; }
function    ..               { cd ..; }
function    ,,               { cd ../..; }
function    p8               { ping  8.8.8.8; }
function    mygetcert        {  echo |     openssl s_client -connect $1 2>/dev/null |     openssl x509 -text ; }
function    cat              {  batcat $@; }
# stty columns 120
# export PYTHONSTARTUP=$HOME/.pythonrc.py
export LC_ALL="en_US.UTF-8"
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export EDITOR="vi"
export VISUAL="vi"
export PATH=$PATH:$HOME/bin/:$HOME/.local/bin
TZ='Asia/Kolkata'; export TZ
# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
umask 022
# dircolors for solarized light
# (from https://github.com/seebi/dircolors-solarized)
[ -f ~/.dircolors ] && eval `dircolors ~/.dircolors`


# Go Global variables
export GOROOT=$HOME/packages/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# side-by-side diff
# P.S. use like this to diff two command outputs:
# mydiff <(cmd1) <(cmd2)
function mydiff()
{
    diff --side-by-side --suppress-common-lines -W $(( $(tput cols) - 2 )) "$@"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# launch $EDITOR with the fzf selection
# source: https://bluz71.github.io/2018/11/26/fuzzy-finding-in-bash-with-fzf.html
fzf_find_edit() {
    local file=$(
      fzf --query="$1" --no-multi --select-1 --exit-0
      )
    if [[ -n $file ]]; then
        $EDITOR "$file"
    fi
}
alias ffe='fzf_find_edit'


# Windows specific hacks
if [ -f /etc/wsl.conf ]; then
		# windows docker server, wsl docker client
		export DOCKER_HOST="tcp://localhost:2375"
fi

# only on my microk8s box
if [ -x /snap/bin/microk8s ]; then
		alias kubectl='microk8s kubectl'
fi

# starship, install using sh install.sh -b ~/bin
# reference: https://starship.rs/install.sh
# eval "$(starship init bash)"
SMILEY="✔"
FROWNY="❌"
GIT_SYMBOL=""
SELECT="if [ \$? = 0 ]; then echo \"${SMILEY}\"; else echo \"${FROWNY}\"; fi"
export PS1="[\t] \[$(tput sgr0)\]\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h: \`${SELECT}\` \[$(tput sgr0)\]\[\033[38;5;6m\][\w] \[$(tput sgr0)\]\[\033[38;5;198m\] ${GIT_SYMBOL} (\$(git branch 2>/dev/null | grep '^*' | colrm 1 2))\[$(tput sgr0)\]\n> \[$(tput sgr0)\]"


# source fzf completions and keybindings
source ~/.fzf/completion.bash  
source ~/.fzf/key-bindings.bash

# exa
if [ -f ~/.exa.bash ]; then
  source ~/.exa.bash
fi

# krew
if [ -d ~/.krew/bin ]; then
  export PATH=$PATH:~/.krew/bin
fi

# jump hosts
if [ -f ~/.jump-hosts ]; then
  source ~/.jump-hosts
fi

# kube-ps1
if [ -f ~/.kube-ps1.sh ]; then
  source ~/.kube-ps1.sh
fi

# work related stuff
if [ -f ~/.bashrc.work ]; then
  source ~/.bashrc.work
fi

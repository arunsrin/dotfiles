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
function    p                { less $@; }
function    et               { emacsclient $@; }
function    e                { emacsclient -c -a emacs $@; }
function    lr               { ls --color=auto -lrt $@; }
function    l                { ls --color=auto $@; }
function    sl               { ls --color=auto $@; }
function    ls               { /bin/ls --color=auto $@; }
function    la               { ls -Fa --color=auto $@; }
function    pd               { pushd $@; }
function    pd2              { pushd +2 $@; }
function    pd3              { pushd +3 $@; }
function    ..               { cd ..; }
function    ,,               { cd ../..; }
function    mygetcert        {  echo |     openssl s_client -connect $1 2>/dev/null |     openssl x509 -text ; }
# stty columns 120
export PS1="[\u@\h \W]\$ "
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
      fzf --query="$1" --no-multi --select-1 --exit-0 \
          --preview 'bat --color=always --line-range :500 {}'
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
eval "$(starship init bash)"

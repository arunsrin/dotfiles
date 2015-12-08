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
function    p               { less $@; }
function    e               { emacs -nw $@; }
function    lr               { ls --color=auto -lrt $@; }
function    l               { ls --color=auto $@; }
function    sl               { ls --color=auto $@; }
function    ls               { /bin/ls --color=auto $@; }
function    la               { ls -Fa --color=auto $@; }
function    pd               { pushd $@; }
function    pd2               { pushd +2 $@; }
function    pd3               { pushd +3 $@; }
function    ..               { cd ..; }
function    ,,               { cd ../..; }
# stty columns 120
export PS1="bash-\v \w$ "
# export PYTHONSTARTUP=$HOME/.pythonrc.py
export LC_ALL="en_US.UTF-8"
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export EDITOR=vim
export PATH=$PATH:$HOME/bin/


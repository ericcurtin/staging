# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
TERM=xterm

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

export PATH="~/git/staging:$PATH"
. git-status-prompt

green="\\[\\033[00;32m\\]"
red="\\[\\033[00;31m\\]"
cyan="\\[\\033[01;36m\\]"
yellow="\\[\\033[01;93m\\]"
nc="\\[\\033[00;00m\\]"
lgreen='\[\033[01;32m\]'
blue='\[\033[01;34m\]'

HOSTNAME_FQDN=$(hostname -f | head -c4)
PS1="$lgreen\u@$HOSTNAME_FQDN \t$nc"
if type GitStatusPrompt > /dev/null 2>&1; then
  PS1="$PS1 \$(es) \$(GitStatusPrompt)"
fi

PS1="$PS1\n$blue\w$nc$ "

es() {
  local errno="$?"

  local nc='\033[0m'

  local r='\033[0;31m'
  local g='\033[0;32m'

  if [ $errno != 0 ]; then
    echo -e "$r$errno$nc"
  else
    echo -e "$g$errno$nc"
  fi
}


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

run() {
  $@ & disown; exit
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

WIN_HOME="/media/sf_c/Users/$USER/"

#. ~/git/staging/.bashrc

update() {
  set -e

  cd /tmp
  sudo apt update
  sudo dpkg --configure -a
  sudo apt -y upgrade
  zoom_url="https://zoom.us/client/latest/zoom_amd64.deb"
  last_modified=$(curl -I -L "$zoom_url" 2>&1 | grep "^Last-Modified:")
  if [ "$(cat /etc/zoom-last.txt)" != "$last_modified" ]; then
    curl -LO https://zoom.us/client/latest/zoom_amd64.deb
    sudo apt -y install /tmp/zoom_amd64.deb
    echo "$last_modified" > /etc/zoom-last.txt
  fi

  sudo apt -y autoremove

  set +e
  sudo fwupdmgr refresh --force
  local ret=$?
  if [ "$ret" -ne 0 ]; then
    echo "'sudo fwupdmgr refresh --force' failed with $ret"
    exit $ret
  fi

  sudo fwupdmgr update
  local ret=$?
  if [ "$ret" -ne 0 ] && [ "$ret" -ne 2 ]; then
    echo "'sudo fwupdmgr update' failed with $ret"
    exit $ret
  fi
}

po() {
  update
  sudo init 0
}

rb() {
  update
  sudo reboot
}

export PATH="$PATH:~/git/staging"


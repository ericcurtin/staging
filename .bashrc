# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PATH="$HOME/git/staging:$HOME/git/dns:/var/lib/snapd/snap/bin:$HOME/.local/bin:$HOME/bin:$PATH"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

update() {
  set -e

  cd /tmp

  local this_update=$(cat /etc/update-counter.txt)
  local this_update_rem=$((this_update % 6))
  if [ "$this_update_rem" -eq "0" ]; then
    sudo dnf upgrade-minimal -y
  elif [ "$this_update_rem" -eq "1" ]; then
    sudo dnf upgrade -y
  elif [ "$this_update_rem" -eq "2" ]; then
    sudo apt update
    sudo setenforce 0 || true
    sudo dpkg --configure -a --force-all
    zoom_url="https://zoom.us/client/latest/zoom_x86_64.rpm"
    last_modified=$(curl -I -L "$zoom_url" 2>&1 | grep "^Last-Modified:")
    if [ "$(cat /etc/zoom-last.txt)" != "$last_modified" ]; then
      curl -LO https://zoom.us/client/latest/zoom_x86_64.rpm
      sudo dnf install -y /tmp/zoom_x86_64.rpm
      echo "$last_modified" > /etc/zoom-last.txt
    fi
#  zotero_url="https://github.com/retorquere/zotero-deb/releases"
#  last_modified=$(curl -L "$zotero_url" 2>&1 | grep zotero*.deb)
#  if [ "$(cat /etc/zotero-last.txt)" != "$last_modified" ]; then
#    sudo apt-get download zotero
#    echo "$last_modified" > /etc/zotero-last.txt
#  fi
#  elif [ "$this_update_rem" -eq "3" ]; then
#    sudo snap refresh
  elif [ "$this_update_rem" -eq "3" ]; then
    set +e
    sudo fwupdmgr refresh --force
    local ret=$?
    if [ "$ret" -ne 0 ] && [ "$ret" -ne 1 ]; then
      echo "'sudo fwupdmgr refresh --force' failed with $ret"
      exit $ret
    fi

    sudo fwupdmgr update
    local ret=$?
    if [ "$ret" -ne 0 ] && [ "$ret" -ne 2 ]; then
      echo "'sudo fwupdmgr update' failed with $ret"
      exit $ret
    fi
  elif [ "$this_update_rem" -eq "4" ]; then
    sudo cpan-outdated -p | sudo cpanm
  elif [ "$this_update_rem" -eq "5" ]; then
    sudo flatpak update -y --noninteractive
  fi

  echo $((this_update + 1)) > /etc/update-counter.txt
}

po() {
  update
  sudo init 0
}

rb() {
  update
  sudo reboot
}

run() {
  $@ & disown; exit
}

green='\[\033[0;32m\]'
red='\[\033[0;31m\]'
cyan='\[\033[1;36m\]'
yellow='\[\033[0;93m\]'
nc='\[\033[0;0m\]'
lgreen='\[\033[1;32m\]'
blue='\[\033[1;34m\]'

es() {
  local errno="$?"

  if [ $errno = 0 ]; then
    echo -en "\033[0;32m$errno"
  else
    echo -en "\033[0;31m$errno"
  fi
}

. git-status-prompt
HOSTNAME_FQDN=$(hostname -f | head -c4)
UNAME_M=$(uname -m)
PS1="$lgreen\u@$HOSTNAME_FQDN $cyan$UNAME_M $lgreen\t \$(es)$nc"
if type GitStatusPrompt > /dev/null 2>&1; then
  PS1="$PS1 \$(GitStatusPrompt)"
fi

PS1="$PS1\n$blue\w$nc$ "

TERM=xterm-256color


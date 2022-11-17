# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PATH="$HOME/.cargo/bin:$HOME/go/bin:$HOME/git/staging:$HOME/git/dns:/var/lib/snapd/snap/bin:$HOME/.local/bin:$HOME/bin:$PATH"

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
  set -ex

  cd /tmp

  local this_update=$(cat /etc/update-counter.txt)
  local this_update_rem=$((this_update % 6))
  if [ "$this_update_rem" -eq "0" ]; then
    sudo dnf upgrade-minimal -y
  elif [ "$this_update_rem" -eq "1" ]; then
    sudo dnf upgrade -y
  elif [ "$this_update_rem" -eq "2" ]; then
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

cosa() {
   env | grep COREOS_ASSEMBLER
   local -r COREOS_ASSEMBLER_CONTAINER_LATEST="quay.io/coreos-assembler/coreos-assembler:latest"
   if [[ -z ${COREOS_ASSEMBLER_CONTAINER} ]] && $(podman image exists ${COREOS_ASSEMBLER_CONTAINER_LATEST}); then
       local -r cosa_build_date_str="$(podman inspect -f "{{.Created}}" ${COREOS_ASSEMBLER_CONTAINER_LATEST} | awk '{print $1}')"
       local -r cosa_build_date="$(date -d ${cosa_build_date_str} +%s)"
       if [[ $(date +%s) -ge $((cosa_build_date + 60*60*24*7)) ]] ; then
         echo -e "\e[0;33m----" >&2
         echo "The COSA container image is more that a week old and likely outdated." >&2
         echo "You should pull the latest version with:" >&2
         echo "podman pull ${COREOS_ASSEMBLER_CONTAINER_LATEST}" >&2
         echo -e "----\e[0m" >&2
         sleep 10
       fi
   fi
   set -x
   podman run --rm -ti --security-opt label=disable --privileged                                    \
              --uidmap=1000:0:1 --uidmap=0:1:1000 --uidmap 1001:1001:64536                          \
              -v ${PWD}:/srv/ --device /dev/kvm --device /dev/fuse                                  \
              --tmpfs /tmp -v /var/tmp:/var/tmp --name cosa                                         \
              ${COREOS_ASSEMBLER_CONFIG_GIT:+-v $COREOS_ASSEMBLER_CONFIG_GIT:/srv/src/config/:ro}   \
              ${COREOS_ASSEMBLER_GIT:+-v $COREOS_ASSEMBLER_GIT/src/:/usr/lib/coreos-assembler/:ro}  \
              ${COREOS_ASSEMBLER_CONTAINER_RUNTIME_ARGS}                                            \
              ${COREOS_ASSEMBLER_CONTAINER:-$COREOS_ASSEMBLER_CONTAINER_LATEST} "$@"
   rc=$?; set +x; return $rc
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


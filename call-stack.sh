#!/bin/bash

set -e

print_callers() {
  local callers=($(git grep -pn $1 | grep "\.c.*=.*=\|\.h.*=.*="))
  for caller in "${callers[@]}"; do
    if echo $caller | grep -q "=.*=static$\|=.*=.*:$\|=.*=.*\*$\|=.*=const$\|=.*=typedef$\|=.*=gboolean$\|=.*=echo$\|.*=G_BEGIN_DECLS$\|.*=OstreeSysroot$\|.*=impl$\|.*=extern$\|.*=void$\|.*=int$\|.*=char$"; then
      continue
    fi

    if echo $caller | grep -q "=.*="; then
      local function_name=$(echo $caller | awk -F= '{printf $3"\n"}')
      echo "$function_name"
      if [ "$function_name" != "main" ]; then
        print_callers $function_name
      else
        echo
      fi
    fi
  done
}

print_callers $1


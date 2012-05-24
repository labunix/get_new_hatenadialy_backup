#!/bin/bash
# Author      : labunix
# Description : DSA Report from http://www.debian.org/security
# Last Update : 2012/05/24
set -e

# for proxy
PROXY="/etc/profile.d/proxy.sh"
test -x "$PROXY" && . "$PROXY"

# for home directory
echo "$HOME" | grep "`whoami`" | HOME="/home/`whoami`"
cd "$HOME" || exit 1

# for debian security URL
HURL="www.debian.org"
test -d "$HURL" || mkdir "$HURL"
cd "$HURL" || exit 1

# diff settings
HGET="getlist.txt"
BASE="base.txt"
COMP="comp.txt"
test -f "$HGET" || touch "$HGET"
test -f "$BASE" || touch "$BASE"
test -f "$COMP" || touch "$COMP"

# get debian security list
w3m -dump "http://${HURL}/security" | grep "\[.*DSA"  > "$COMP"

# diff to BASE ?
diff --left-column "$BASE" "$COMP" | sed s/"> "//g | grep "DSA" > "$HGET"

# mail
if [ -s "$HGET" ];then
  cat "$HGET" | mail -s "Debian Security Report" root
  mv "$COMP" "$BASE"
else
  echo "Do Nothing"
fi

unset PROXY HOME HURL HDAY HGET BASE COMP
exit 0

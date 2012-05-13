#!/bin/bash
# Author      : labunix
# Description : backup http://labunix.hateblo.jp 
# Last Update : 2012/05/12
set -e

# for proxy
PROXY="/etc/profile.d/proxy.sh"
test -x "$PROXY" && . "$PROXY"

# for home directory
echo "$HOME" | grep "`whoami`" | HOME="/home/`whoami`"
cd "$HOME" || exit 1

# for Hatena Blog Beta URL
HURL="labunix.hateblo.jp"
test -d "$HURL" || mkdir "$HURL"
cd "$HURL" || exit 1

# diff settings
HDAY="`env LANG=C date '+%Y%m%d'`.log" 
HGET="getlist.txt"
BASE="base.txt"
COMP="comp.txt"
test -f "$HDAY" || touch "$HDAY"
test -f "$HGET" || touch "$HGET"
test -f "$BASE" || touch "$BASE"
test -f "$COMP" || touch "$COMP"

# xml to URL list
w3m -dump_source "http://${HURL}/sitemap.xml" | \
  sed s/'>'/"\n"/g | grep "^http.*[0-9]" | \
  awk -F\< '{print $1}' > "$COMP"

# diff to URL lists
diff --left-column "$BASE" "$COMP" | sed s/"> "//g | grep "^http" > "$HGET"

# getlist
if [ -s "$HGET" ];then
  for list in `cat "$HGET"`;do
    hatena_blogbeta=`echo "$list" | sed s%".*entry"%%g | \
      awk -F\/ '{print $2$3$4"_"$5}'`
    echo "$list -> $hatena_blogbeta" | tee -a "$HDAY"
    w3m -dump "$list" > "$hatena_blogbeta" 2>> "$HDAY"
  done
  mv "$COMP" "$BASE"
  unset list hatena_blogbeta
else
  echo "Do Nothing"
fi
unset PROXY HOME HURL HDAY HGET BASE COMP
exit 0

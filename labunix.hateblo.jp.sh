#!/bin/bash

SAVE=~/hatena2
test -d "$SAVE" || mkdir "$SAVE"
test -d "$SAVE" || exit 1
test -d "$SAVE" && cd "$SAVE"

LOG=`echo $0 | sed s%".*/"%%g | sed s/".sh"/".log"/`
test -f $LOG || touch $LOG

w3m -dump "http://labunix.hateblo.jp/sitemap.xml" | \
  sed s/"<"/"\n&"/g | grep "<loc>" | sed s/"<loc>"// | \
  sed s/"^"/"\""/g | sed s/"\$"/"\""/g | \
  for site in `xargs`;do 
    w3m -dump "$site" | \
      sed s/"<"/"\n&"/g | grep entry | \
      grep "<loc>" | sed s/"<loc>"//g | \
      for list in `xargs`;do
        OUT=`echo "$list" | sed s%".*entry/"%% | \
          sed s%"\(20[0-9][0-9][01][0-9][0-3][0-9]\)/"%"\1_"% | \
          sed s%"\(20[0-9][0-9]\)/\([01][0-9]\)/\([0-3][0-9]\)"%"\1\2\3"%g | \
          sed s%"/"%"_"%g`
        if [ -f "$OUT" ];then
          echo "$OUT is here."
        else
          w3m -dump "$list" > $OUT && echo "$OUT done." | tee -a $LOG
        fi
      done
  done
unset OUT LOG SAVE
exit 0


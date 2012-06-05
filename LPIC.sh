#!/bin/bash

# 実行するユーザに注意
set -e

if [ `id -u` -lt 500 ] ;then
  echo "Sorry! Not Permit User"
  exit 1
fi
PROXY="/etc/profile.d/proxy.sh"
test -x ${PROXY} && . ${PROXY}
MYPWD=~/myscripts/LPIC
test -d ${MYPWD} || mkdir -p ${MYPWD}
if [ ! -d "${MYPWD}" ];then
  echo "Error, Not FOUND ${MYPWD}"
  exit 1
fi
cd ${MYPWD}

GETURL="http://www.oss-db.jp"
GETFILE="OSS-DB.get"
OLDFILE="OSS-DB.old"
MYREPORT="LPIC_report_mail.txt"

touch ${GETFILE}
touch ${OLDFILE}
touch ${MYREPORT}

# 記事のバックアップが無ければ取得する
# 取得したバックアップに「このエントリ」を含む行を取得する
# 

w3m -dump ${GETURL} > ${GETFILE}
diff --left-column ${GETFILE} ${OLDFILE} | sed s/"<"//g > ${MYREPORT}
if [ ! -s ${MYREPORT} ] ;then
  echo "Do nothing"
else
  cat ${MYREPORT} | sed s/">"//g | \
    mail -s "New LPIC Reports" `whoami`@`hostname -f`
  mv ${GETFILE} ${OLDFILE}
fi

unset PROXY MYPWD GETURL GETFILENAME OLDFILENAME MYREPORT
exit 0

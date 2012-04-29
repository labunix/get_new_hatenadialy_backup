#!/bin/bash

# 環境変数の取り込みとはてなダイヤリーのバックアップディレクトリに移動
# 実行するユーザに注意
set -e
MYPWD=~/hatena
if [ ! -d "${MYPWD}" ];then
  echo "Error, Not FOUND ${MYPWD}"
  exit 1
fi
cd ${MYPWD}

# はてなユーザを変数で定義する
# あなたが「labunix」以外のユーザのはてなダイヤリーの最新記事をバックアップ
# したいと望むならここを書き換えてください。

USER=labunix

# RSS2から最新のはてなダイヤリーのURLを取得
# 例えば、以下のような形式
# http://d.hatena.ne.jp/labunix/20120423

GETURL=$(w3m -dump "http://d.hatena.ne.jp/${USER}/rss2" | \
  grep "^\|^" | sed s/"\|\|\|"//g | \
  grep "<title>\|<link>" | \
  awk '{if(NR==4) print}' | sed s%"<link>\|</link>"%%g)

# はてなダイヤリーの記事固有のディレクトリ部分を取得
# 以下の形式
# yyyymmdd

GETFILENAME=$(echo ${GETURL} | awk -F\/ '{print $5}')

# 記事のバックアップが無ければ取得する
# 取得したバックアップに「このエントリ」を含む行を取得する
# 

if [ -f "${GETFILENAME}" ];then
  echo "Do Nothing"
else
  w3m -dump "${GETURL}" > "${GETFILENAME}"
  LINKURL="`head -20 "${GETFILENAME}" | grep ^20 | sed s/"このエントリ.*"//g`"
  echo  "<a title="\"${LINKURL}\"" href="\"http:/d.hatena.ne.jp/${USER}/${list}/\"" target="\"about:blank\"">${LINKURL}</a>" >> mydaialy_link.txt

  # システムメールでお知らせ
  # 不要ならコメントアウトしても動作に支障は無い

  cat mydaialy_link.txt | mail -s "New Hatena Blog Backup" `whoami`

fi

unset MYPWD
unset GETURL
unset GETFILENAME
unset LINKURL
exit 0

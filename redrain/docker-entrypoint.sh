#!/bin/bash
set -e

if [ -f $DIR/$NAME.py ]; then
  rm -rf /root/.pm2/logs/* 2>/dev/null
  cd $DIR
  pm2 start $NAME.py -x --watch --ignore-watch "*.se* *.list *.txt *.sh *.yml *.log .* *.bak*"
fi

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- python "$@"
fi

exec "$@"

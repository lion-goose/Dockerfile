#!/bin/sh
set -e

#sunert 仓库的百度极速版
if [ -d "/get_CCB" ]; then
    echo "git pull拉取最新代码..."
    cd /get_CCB
    git -C /get_CCB --rebase
fi

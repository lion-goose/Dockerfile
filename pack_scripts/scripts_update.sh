#!/bin/sh
set -e

#sunert 仓库的百度极速版
if [ -d "/get_CCB" ]; then
    echo "Pull the get_CCB latest code..."
    echo "git 拉取get_CCB最新代码..."
    git -C /get_CCB reset --hard
    git -C /get_CCB pull
    cd /get_CCB
    pip3 install -r requirements.txt
fi

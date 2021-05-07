#!/usr/bin/env bash
set -e

# 安装leeyiding/get_CCB仓库依赖
function initCcbPythonEnv() {
  echo "开始安装运行get_CCB需要的python环境及依赖..."
  apk add --update python3-dev py3-pip
  echo "开始安装jdbot依赖..."
  cd /get_CCB
  pip3 install --upgrade pip
  pip3 install -r requirements.txt
}

# 下载leeyiding/get_CCB仓库
function initCcb() {
    git clone https://github.com/leeyiding/get_CCB.git /get_CCB
}

function main(){
    if [ ! -d "/get_CCB/" ]; then
        echo "未检查到get_CCB仓库脚本，初始化下载相关脚本"
        initCcb
    else
        echo "更新lion-goose脚本相关文件"
        git -C /get_CCB reset --hard
        git -C /get_CCB pull --rebase
    fi
    cp /scripts/logs/config.json /get_CCB/config.json
    initCcbPythonEnv
}
main


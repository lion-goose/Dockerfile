#!/usr/bin/env bash
set -e

# 安装leeyiding/get_CCB仓库依赖
function initCcbPythonEnv() {
  echo "开始安装运行get_CCB需要的python环境及依赖..."
  apk add --update python3-dev py3-pip
  echo "开始安装get_CCB依赖..."
  cd /wget_CCB
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
        echo "更新get_CCB仓库相关脚本文件"
        git -C /get_CCB reset --hard
        git -C /get_CCB pull --rebase
    fi
    if [ -f "/get_CCB/config.json" ]; then
        echo "存在cookie配置文件，跳过操作..."
    else
        echo "复制cookie配置文件..."
        cp /scripts/logs/config.json /get_CCB/config.json
    fi
    if type python3 >/dev/null 2>&1; then
        cd /get_CCB
        pip3 install -r requirements.txt
        echo "get_CCB所需环境已经存在，跳过安装依赖环境"
    else
        echo "get_CCB所需环境不存在，初始化所需python3及依赖环境"
        initCcbPythonEnv
    fi
    echo "48 */3 * * * cd /get_CCB/ && python3 keepAlive.py |ts >> /scripts/logs/ccbkeepAlive.log 2>&1" >> /scripts/docker/merged_list_file.sh
    echo "12 9,21 * * * cd /get_CCB/ && python3 main.py |ts >> /scripts/logs/ccbmain.log 2>&1" >> /scripts/docker/merged_list_file.sh
}
main


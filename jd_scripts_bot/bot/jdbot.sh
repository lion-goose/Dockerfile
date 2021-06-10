#!/bin/sh
set -e

JDS_DIR='/jds/jd_scripts_bot'
BASE_DIR='/scripts'

# bot更新了新功能的话只需要重启容器就完成更新
function initBotPythonEnv() {
  echo "开始安装运行jdbot需要的python环境及依赖..."
  apk add --update python3-dev py3-pip py3-cryptography py3-numpy py-pillow
  echo "开始安装jdbot依赖..."
  cd "$JDS_DIR/bot"
  pip3 install --upgrade pip
  pip3 install -r requirements.txt
  python3 setup.py install
}

function start() {
  if type python3 >/dev/null 2>&1; then
    echo "jdbot所需环境已经存在，跳过安装依赖环境"
    if [[ "$(pip3 list | grep myqr)" == "" ]]; then
        echo "jdbot所需环境不完整，初始化所需python3及依赖环境"
        initBotPythonEnv
    fi
  else
    echo "jdbot所需环境不存在，初始化所需python3及依赖环境"
    initBotPythonEnv
  fi
  echo '更新bot代码...'
  cd "$JDS_DIR/bot"
  python3 setup.py install

  AS=$(ps -ef | grep "jdbot.py" | grep -v "grep" | awk '{print $1}')
  if [ -n "$AS" ]; then
    echo "jd bot 已经启动，跳过..."
  else
    echo "启动jd bot..."
    echo " " >"$BASE_DIR/logs/jdbot.log"
    jdbot.py >>"$BASE_DIR/logs/jdbot.log" 2>&1 &
    echo "jd bot已启动..."
  fi
}

start


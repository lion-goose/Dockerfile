#!/bin/sh
set -e

#获取配置的自定义参数
if [ $1 ]; then
    run_cmd=$1
fi
[ -f /scripts/package.json ] && before_package_json=$(cat /scripts/package.json)
if [ -f "/scripts/logs/pull.lock" ]; then
  echo "存在更新锁定文件，跳过git pull操作..."
else
  echo "设定远程仓库地址..."
  cd /scripts
  git remote set-url origin "$REPO_URL"
  git reset --hard
  echo "git pull拉取最新代码..."
  git fetch --all
  git reset --hard origin/main
  if [ ! -d /scripts/node_modules ]; then
    echo "容器首次启动，执行npm install..."
    npm install --loglevel error --prefix /scripts
#   else
#     if [[ "${before_package_json}" != "$(cat /scripts/package.json)" ]]; then
#       echo "package.json有更新，执行npm install..."
#       npm install --loglevel error --prefix /scripts
#     else
#       echo "package.json无变化，跳过npm install..."
#     fi
  fi
fi

#任务脚本shell仓库
cd /jds
git pull origin master --rebase

echo "------------------------------------------------执行定时任务任务shell脚本------------------------------------------------"
sh /jds/jd_scripts/task_shell_script.sh
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"

if [[ "${before_package_json}" != "$(cat /scripts/package.json)" ]]; then
  echo "package.json有更新，执行npm install..."
  npm install --loglevel error --prefix /scripts
  before_package_json=$(cat /scripts/package.json)
else
  echo "package.json无变化，跳过npm install..."
fi

if [ $run_cmd ]; then
    echo "Start crontab task main process..."
    echo "启动crondtab定时任务主进程..."
    crond -f
else
    echo "默认定时任务执行结束。"
fi

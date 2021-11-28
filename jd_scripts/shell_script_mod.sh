#!/usr/bin/env bash
set -e

mergedListFile="/scripts/docker/merged_list_file.sh"

echo "附加功能1，backup仓库脚本"

function initLiongoose() {
    git clone https://github.com/lion-goose/BackUp.git /lion-goose
}

if [ ! -d "/lion-goose/" ]; then
    echo "未检查到lion-goose仓库脚本，初始化下载相关脚本"
    initLiongoose
else
    echo "更新lion-goose脚本相关文件"
    git -C /lion-goose reset --hard
    git -C /lion-goose pull --rebase
    #npm install --loglevel error
fi

##复制两个文件
cp -f /lion-goose/jd*.js /scripts/
cp -f /lion-goose/TS_USER_AGENTS.js /scripts/
cp -f /lion-goose/package.json /scripts/
cp -f /lion-goose/xmSports.js /scripts/
echo "18 */6 * * * node /scripts/jd_api_test.js |ts >> /scripts/logs/jd_api_test.log 2>&1" >> /scripts/docker/merged_list_file.sh

#附加功能2,拉取JDHelloWorld仓库的代码，并增加相关任务
function initJDHelloWorld() {
    git clone https://github.com/JDHelloWorld/jd_scripts.git /JDHelloWorld
}

function JDHelloWorld() {
    if [ ! -d "/JDHelloWorld/" ]; then
        echo "未检查到JDHelloWorld仓库脚本，初始化下载相关脚本"
        initJDHelloWorld
    else
        echo "更新JDHelloWorld脚本相关文件"
        git -C /JDHelloWorld reset --hard
        git -C /JDHelloWorld pull --rebase
    fi
    ##复制文件
    cp -f /JDHelloWorld/*.js /scripts/
    
}
JDHelloWorld

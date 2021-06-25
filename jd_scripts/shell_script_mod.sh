#backup仓库脚本
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

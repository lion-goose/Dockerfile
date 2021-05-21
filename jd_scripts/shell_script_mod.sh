#backup仓库脚本
function initLiongoose() {
    git clone https://github.com/lion-goose/BackUp.git /lion-goose
}

function LiongooseBackup() {
    if [ ! -d "/lion-goose/" ]; then
        echo "未检查到lion-goose仓库脚本，初始化下载相关脚本"
        initLiongoose
    else
        echo "更新lion-goose脚本相关文件"
        git -C /lion-goose reset --hard
        git -C /lion-goose pull --rebase
    fi
    ##复制文件
    cp -f /lion-goose/jd*.js /scripts/
    echo "0,1 0 * * * node /scripts/jd_jxcfdtx.js |ts >> /scripts/logs/jd_jxcfdtx.log 2>&1" >> /scripts/docker/merged_list_file.sh
    
}
LiongooseBackup

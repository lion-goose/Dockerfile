#!/bin/sh


mergedListFile="/scripts/docker/merged_list_file.sh"

echo "附加功能1，使用jds仓库的genCodeConf.list文件"
cp /jds/dd_scripts/genCodeConf.list "$GEN_CODE_LIST"

echo "附加功能2，创建其他任务"
if [ ! -d "/scripts/somescripts/" ]; then
    echo "任务文件不存在，创建任务文件夹"
    cp -r /data/somescripts/ /scripts/somescripts
else
    echo "任务存在，跳过..."
fi
echo "创建其他定时任务"
echo "# 百度和中青任务" >> $mergedListFile
echo "*/30 5-23 * * * node /scripts/somescripts/youth/youth.js >> /scripts/logs/youth.log 2>&1" >> $mergedListFile
echo "15 5,8,11,14,17,20 * * * node /scripts/somescripts/youth/Youth_Read-ange.js >> /scripts/logs/Youth_Read-ange.log 2>&1" >> $mergedListFile
echo "45 6,9,12,15,18,21 * * * node /scripts/somescripts/youth/Youth_Read-hexor.js >> /scripts/logs/Youth_Read-hexor.log 2>&1" >> $mergedListFile
echo "*/30 5-23 * * * node /scripts/somescripts/baidu/baidu_speed.js >> //scripts/logs/baidu_speed.log 2>&1" >> $mergedListFile

echo "附加功能3，拉取zooPanda仓库的代码，并增加相关任务"
if [ ! -d "/data/cust_repo/zoo/" ]; then
    echo "未检查到zooPanda仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/zooPanda/zoo.git /data/cust_repo/zoo
else
    echo "更新zooPanda脚本相关文件..."
    git -C /data/cust_repo/zoo reset --hard
    git -C /data/cust_repo/zoo pull --rebase
fi
rm -rf /scripts/zoo*
for jsname in $(find /data/cust_repo/zoo -name "zoo*.js"); do cp ${jsname} /scripts; done
# for jsname in $(find /scripts -name "zoo*.js"); do
#     jsnamecron="$(cat $jsname | grep -oE ".*cron.*" | cut -d ":" -f2)"
    test -z "$jsnamecron" || echo "$jsnamecron node /scripts/$jsname >> /scripts/logs/$jsname.log 2>&1" >> /scripts/docker/merged_list_file.sh
done
